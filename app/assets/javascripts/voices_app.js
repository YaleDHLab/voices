// compile all required controllers into one app to expose to views
var VoicesApp = angular.module('VoicesApp', ['ngFileUpload', 'uiSwitch', 'angularModalService']);


// service to return the current page class (record, annotatate, edit)
VoicesApp.service('pageClassService', 
  function () {
    this.getPageClass = function() {
      var url = window.location.href;
      var currentPageClass = ''
      if (url.indexOf("/annotate") > -1) {
        currentPageClass = "annotate";
      }
      if (url.indexOf("/records") > -1) {
        currentPageClass = "show";
      }
      if (url.indexOf("/new") > -1) {
        currentPageClass = "new";
      }
      if (url.indexOf("/edit") > -1) {
        currentPageClass = "edit";
      }

      return currentPageClass;
    };
  }
);


/***
* general service for placing http requests. Results may be fetched like this:
*
* var config = {"method": "get", "url": "/user/show.json"};
*
* httpService.placeRequest(config).then(
*      function(d) {
*        console.log(d);
*     }
*  );
*
***/
VoicesApp.factory('httpService', [
      '$http',
  function ($http) {
    return {
      placeRequest: function(config) {
        // this function returns a promise
        return $http(config);  
      }
    };
  }
]);



// service to POST a new record form with user params
VoicesApp.service('postRecordForm', [
      '$http',
  function ($http) {
    this.uploadForm = function(form){
      
      // retrieve the CSRF token to we can make the POST request without getting 422'd
      var csrfToken = $('meta[name="csrf-token"]').attr('content');
      var myRecordUrl = "/records";

      /*
      // to manually build up form:
      var fd = new FormData();
      fd.append('record[title]', form.title );
      fd.append('record[make_private]', form.make_private );
      fd.append('record[description]', form.description );
      fd.append('record[hashtag]', form.hashtag );
      fd.append('record[release_checked]', form.release_checked == true? "1" : "0" );
      fd.append('record_attachments[files]', form.release_checked == true? "1" : "0" );
      */

      fd = new FormData;

      for (var k in form) {
        fd.append('record[' + k + ']', form[k]);
      };

      var req = {
        method: 'POST',
        url: myRecordUrl,
        headers: {
          'Content-Type': undefined,
          'X-CSRF-Token': csrfToken
        },
        data: fd
      };

      $http(req)
        .success(function(){
          })
        .error(function(){
          });
    }
  }
]);




// service to POST attachment annotations to db
VoicesApp.service('saveAnnotationService', [
  function () {
    this.saveAnnotation = function(annotation, attachmentId) {
      $.ajax({ url: "/record_attachments/" + attachmentId + ".json",
        type: 'PUT',
        beforeSend: function(xhr) {xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))},
        data: {"annotation": annotation},
        success: function(response) {}
      });
    }
  }
]);







VoicesApp.controller("FormController", [
        "$scope", "$http", "$location", "Upload", "postRecordForm", "pageClassService",
  function($scope, $http, $location, Upload, postRecordForm, pageClassService ) {

    $scope.filesToSend = []; // array of timestamped filenames to upload 
    $scope.filesSent = []; // array of timestamped filenames uploaded 
    $scope.filesInTransit = {}; // object to store progress of files in transmission
    $scope.recordAttachments = []; // array of objects to populate record attachments in form
    $scope.form = $scope.form ? $scope.form : {}; // record form

    // initialize privacy settings to keep records private
    $scope.form.make_private = $scope.form.make_private? $scope.form.make_private: true;

    // transmit page class so we can distinguish between record#new and record#edit forms
    $scope.currentPageClass = pageClassService.getPageClass();

    // function to be called by view to determine if filesToUpload is populated
    $scope.isNotEmpty = function (obj) {
      for (var i in obj) if (obj.hasOwnProperty(i)) return true;
      return false;
    };

    // setter for form elements; only to be called when user is editing record
    // TODO: Make into a service that returns response.data.record
    $scope.getAttachments = function(recordId) {
      if (recordId) {
          $http.get("/records/" + recordId + ".json")
        .then(function(response) {
          // on success
          $scope.form = response.data.record;
          
        }, // on failure
          function(response) {
            console.log("http request failed", response.status);
          }
        )
      } 
    };

    // if we are in an edit page, then set the form scope by running 
    // a get request for the current record
    // TODO FACTOR HTTP GET RECORD REQUEST OUT OF FORM AND GALLERY APP
    // on page load, parse the requested record and page number from the params
    var url = window.location.href;

    // to keep the code dry, use controller for record#show, record#annotate
    // and record#edit so parse url accordingly. First remove trailing edit from url
    if (url.indexOf("/edit") > -1) {
      url = url.replace("/edit", "");
    }

    // then parse the record id
    if (url.indexOf("/records/") > -1) {
      var recordId = Number( url.split("records/")[1].split("?")[0].split(".")[0] );
    } 

    // save the recordId for future requests
    $scope.recordId = recordId;
    $scope.getAttachments($scope.recordId);
   
    // nb: to submit a record form with current params, we can call:
    //postRecordForm.uploadForm($scope.form);
    // this requires that $scope.form be defined, and that all elements
    // be tied to the form element



    // function for adding or removing image record attachment attributes to/from the form
    $scope.updateAttachmentsInForm = function(method, fileInTransit, size) {
      var file = fileInTransit.file;
      var timestamp = fileInTransit.timestamp;
      var timestampedFilename = file.name + "?" + timestamp;
      var fileAttributes = {
        "filename": file.name,
        "mimetype": file.type,
        "file_upload_url": $scope.aws.rooturl + size + "/" + encodeURIComponent(timestampedFilename),
        "medium_image_url": $scope.aws.rooturl + "medium" + "/" + encodeURIComponent(timestampedFilename),
        "annotation_thumb_url": $scope.aws.rooturl + "annotation_thumb" + "/" + encodeURIComponent(timestampedFilename),
        "square_thumb_url": $scope.aws.rooturl + "square_thumb" + "/" + encodeURIComponent(timestampedFilename)
      };

      if (method == "add") {
        for (var k in fileAttributes) {
          $scope.recordAttachments.push(
            {
              "name": "record[record_attachments_attributes][][" + k + "]",
              "value": fileAttributes[k]
            }
          );
        } 
      } 
      else if (method == "remove" && file.type.indexOf("video") == -1) {
        for (var k in fileAttributes) {
          $scope.recordAttachments.pop(
            {
              "name": "record[record_attachments_attributes][][" + k + "]",
              "value": fileAttributes[k]
            }
          );
        }
      }
      else if (method == "remove" && file.type.indexOf("video") > -1) {
        var req = {
          method: 'DELETE',
          url: "/destroy_unsaved_attachments?filename=" + file.name + 
               "&client_side_timestamp=" + timestamp,
          headers: {
              "Content-Type": undefined,
              "X-CSRF-Token": $('meta[name="csrf-token"]').attr('content')
              },
          data: {}
        };

        $http(req)
          .success( function( response ){
            console.log("deleted attachments", response.status);
          })
          .error( function( response ){
            console.log("a problem occurred while deleting record attachments", 
            response.status);
          });
      }; // closes conditional that sends delete request to server
    } // closes function


    // specify aws file upload params
    $scope.aws = {
      "AWSAccessKeyId": "AKIAJ56CZLFX4U3V7ISQ",
      "policy": "eyJleHBpcmF0aW9uIjoiMjAyMC0wMS0wMVQwMDowMDowMFoiLCJjb25kaXRpb25zIjpbeyJidWNrZXQiOiJ2b2ljZXMtdXNlci11cGxvYWRzIn0sWyJzdGFydHMtd2l0aCIsIiRrZXkiLCIiXSxbInN0YXJ0cy13aXRoIiwiJGZpbGVuYW1lIiwiIl0sWyJzdGFydHMtd2l0aCIsIiRDb250ZW50LVR5cGUiLCIiXSx7ImFjbCI6InB1YmxpYy1yZWFkIn1dfQo=",
      "signature": "nitsVMbBmAnDcBClrp6QTS3VmdI=",
      "acl": "public-read",
      "rooturl": 'https://voices-user-uploads.s3.amazonaws.com/'
    };


    // upload files directly to S3
    var sendFileToAWS = function(file, filesize, timestamp) {
      var timestampedFilename = file.name + "?" + timestamp;
      var contentType = file.type != '' ? file.type : 'application/octet-stream';
      
      // only store this as a file to send if we haven't done so already
      $scope.filesToSend.push(timestampedFilename + filesize);

      file.upload = Upload.upload({
        url: $scope.aws.rooturl, //S3 upload url including bucket name
        method: 'POST',
        data: {
          key: filesize + "/" + timestampedFilename, // Path to file in S3
          AWSAccessKeyId: $scope.aws.AWSAccessKeyId, // AWS Access Key
          acl: $scope.aws.acl, // ACL for file: private, public-read, ...
          policy: $scope.aws.policy, // Base64 policy document
          signature: $scope.aws.signature, // Base64 string based on policy
          "Content-Type": contentType, // mimetype of the file (if non-empty)
          filename: file.name, // needed for Flash polyfill IE8-9
          file: file // the file to be uploaded
        }
      });

      file.upload.then( function (resp) {
          // store the sent file if the user didn't cancel this request
          if ($scope.filesToSend.indexOf(timestampedFilename + filesize) > -1) {
            $scope.filesSent.push(timestampedFilename + filesize);
          };

          // add the original upload file data to the record attachments hash
          // and then submit the record attachment information with the form
          if (filesize === "original") {
            var fileInTransit = $scope.filesInTransit[timestampedFilename];
            $scope.updateAttachmentsInForm("add", fileInTransit, filesize);
          };

      }, function (resp) {
          // log the error callback if the user didn't cancel this request
          if ($scope.filesToSend.indexOf(timestampedFilename + filesize) > -1) {
            $scope.filesSent.push(timestampedFilename + filesize);
          };
          
          // if the user cancelled their upload, response will == -1; 
          // don't log those responses
          if (resp.status != -1) {
            console.log(
              "Error uploading: " + resp.config.data.filename + "; " +
              "Response status: " + resp.status + "; " +
              "Status text: " + resp.statusText
            );
          }
          
          
      }, function (evt) {
          // Tie a progress value to this size of this file.
          // Use Math.min to fix an IE bug that lets progress to go 200%
          // Check if the key exists in the dict before pushing a progress event 
          // update to it, as users can remove k/v pairs from this object 
          // with the cancel all button
          if ($scope.filesInTransit[timestampedFilename]) {
            $scope.filesInTransit[timestampedFilename]["progress"][filesize] = 
            Math.min(100, parseInt(100.0 * evt.loaded / evt.total));
          };
      }); // closes serverside file upload callback


      // expose function that allows user to cancel the upload of a file
      $scope.abort = function(fileInTransit) {        
        var timestampedFilename = fileInTransit.name + "?" + 
          fileInTransit.timestamp;
        
        $scope.filesInTransit[timestampedFilename].file.upload.abort();
        $scope.updateAttachmentsInForm("remove", fileInTransit, filesize);
        
        delete $scope.filesInTransit[timestampedFilename];

        for (i = 0; i < $scope.imageSizes.length; i++) {
          var filesize = $scope.imageSizes[i].filesize;

          var index = $scope.filesToSend.indexOf(
              timestampedFilename + filesize);
          if (index > -1) {
            $scope.filesToSend.splice(index, 1);
          };

          var sentIndex = $scope.filesSent.indexOf(
              timestampedFilename + filesize);
          if (sentIndex > -1) {
            $scope.filesSent.splice(sentIndex, 1);
          };
        }; // closes loop over filesizes
      }; // closes abort()

    }; // closes sendFileToAWS();



    // function called by button click and drag and drop behavior to
    // upload files to rails server
    var sendFileToServer = function(file, filesize, timestamp) {
      var timestampedFilename = file.name + "?" + timestamp;
      $scope.filesToSend.push(timestampedFilename);

      var csrfToken = $('meta[name="csrf-token"]').attr('content');
      var formData = {
        "file_upload": file, 
        "file": "in file_upload",
        "filename": file.name,
        "client_side_timestamp": timestamp
      };

      // include record Id so server knows to attribute this record with the current user
      if ($scope.recordId) {
        formData["file_upload[record_id]"] = $scope.recordId;
      };

      file.upload = Upload.upload({
        url: "/record_attachments",
        method: 'POST',
        // pass in a hash that provides the requisite hash key (file_upload) and dummy file key
        data: formData,
        headers: {'X-CSRF-Token': csrfToken},
        // specify below the model and database column in which we'll store uploads
        fileFormDataName: 'record_attachment[file_upload]', 
        formDataAppender: function(fda, key, val) {
          if (angular.isArray(val)) {
                angular.forEach(val, function(v) {
                  fda.append('record_attachment['+key+']', v);
              });
          } else {
              fda.append('record_attachment['+key+']', val);
          }
        }
      });

      file.upload.then( function (resp) {
        // store the sent file, unless the user canceled the upload
        if ($scope.filesToSend.indexOf(timestampedFilename) > -1) {
          $scope.filesSent.push(timestampedFilename);
        }   

      }, function (resp) {
        // store the sent file, unless the user canceled the upload
        if ($scope.filesToSend.indexOf(timestampedFilename) > -1) {
          $scope.filesSent.push(timestampedFilename);
        } 
        
        // if the user cancelled an upload, we'll get response == -1; 
        // don't log those responses 
        if (resp.status != -1) {
          console.log(
            "Error uploading: " + resp.config.data.file_upload.name + "; " +
            "Response status: " + resp.status + "; " +
            "Status text: " + resp.statusText
          );
        }
        
          
      }, function (evt) {
          // Tie a progress value to this size of this file.
          // Use Math.min to fix an IE bug that lets progress to go 200%
          // Check if the key exists in the dict before pushing a progress event 
          // update to it, as users can remove k/v pairs from this object 
          // with the cancel all button
          if ($scope.filesInTransit[timestampedFilename]) {
            $scope.filesInTransit[timestampedFilename]["progress"][filesize] = 
            Math.min(100, parseInt(100.0 * evt.loaded / evt.total));
          };
      }); // closes serverside file upload callback


      // expose function that allows user to cancel the upload of a file
      $scope.abort = function(fileInTransit) {        
        var timestampedFilename = fileInTransit.name + "?" + 
          fileInTransit.timestamp;
        
        $scope.filesInTransit[timestampedFilename].file.upload.abort();
        delete $scope.filesInTransit[timestampedFilename];
        
        $scope.updateAttachmentsInForm("remove", fileInTransit, "original");

        // remove the file from the list of files to send and sent files
        var index = $scope.filesToSend.indexOf(timestampedFilename);
        if (index > -1) {
          $scope.filesToSend.splice(index, 1);
        };

        var sentIndex = $scope.filesSent.indexOf(timestampedFilename);
        if (sentIndex > -1) {
          $scope.filesSent.splice(sentIndex, 1);
        };
      }; // closes abort()

    }; // closes sendFileToServer()


    // expose function that cancels all pending user uploads
    $scope.cancelAll = function() {
      for (var f in $scope.filesInTransit) {
        $scope.abort($scope.filesInTransit[f]);
        
        // delete the k/v pair from the filesInTransit object
        delete $scope.filesInTransit[f];

        // remove all objects from the filesToSend and filesSent arrays
        $scope.filesToSend = [];
        $scope.filesSent = [];
      }
    };
    
    
    // function to ensure that an uploaded file
    // is below the max file size
    $scope.fileTooLarge = function(file) {
      // create 100mb file with the following command:
      // dd if=/dev/random of=bigfile bs=1024 count=102400
      // then use that byte size as max for uploaded files
      if (file.size > 104857600) {
        $('#file-too-large-modal').modal();
        return true;
      };
      return false;
    };


    // define the array of desired image sizes 
    $scope.imageSizes = [
      {"filesize": "original"},
      {"width": 500, "filesize": "medium"}, 
      {"width": 300, "height": 200, "centerCrop": true, "filesize": "annotation_thumb"},
      {"width": 200, "height": 200, "centerCrop": true, "filesize": "square_thumb"} 
    ];

    // function called by both dragged files and browsed files for uploading files
    var uploadAllFiles = function(files) {
      
      // iterate over files, upload and set progress bar for each
      for (i=0; i < files.length; i++)  {
        
        // if the file's too large, show the client a modal; else upload the file
        if ( $scope.fileTooLarge(files[i]) ) {
        } else {

          // generate a timestamp to associate with the current file
          var timestamp = String(Date.now());

          // use the uploaded file's name and current timestamp as a unique
          // key in the filesInTransit object (in case user uploads multiple files
          // with the same name), and create a progress object that will store
          // the upload progress of each size format for the current file
          $scope.filesInTransit[files[i].name + "?" + timestamp] = {
            "name": files[i].name, 
            "progress": {},
            "file": files[i],
            "timestamp": timestamp,
            "tries": 1
          };

          // if the file is a video file, send it to the Rails backend for processing
          if (files[i].type.indexOf("video") > -1) {
            sendFileToServer(files[i], "original", timestamp);

          // else, send the original directly to AWS
          } else {sendFileToAWS(files[i], "original", timestamp);};

          // if the file is an image, upload the image in each of the desired sizes
          // direct to AWS
          if (files[i].type.indexOf("image") > -1) {
            
            for (j = 0; j < $scope.imageSizes.length; j++) {
              var imageSize = $scope.imageSizes[j];

              // we just uploaded the original, so upload all other sizes
              if (imageSize.filesize != "original") {                
                $scope.uploadResizedImage(files[i], imageSize, timestamp);
              }

            }; // closes file sizes loop
          }; // closes image conditional
        }; // closes file too large conditional
      }; // closes file upload for loop
    };
    

    $scope.uploadResizedImage = function(file, sizeParams, timestamp) {
      Upload.resize(
        file, // file to resize
        sizeParams.width ? sizeParams.width : null, // cropped width
        sizeParams.height, // cropped height
        1, // crop quality
        null, // file type
        null, // cropped image ratio
        sizeParams.centerCrop == true ? true : null, // center crop?
        null // resize conditional
      )
      .then(
        function(resizedImage) {
          sendFileToAWS(resizedImage, sizeParams.filesize, timestamp);
        }
      );
    };

    
    // function to return the aggregate progress of a file upload
    $scope.getProgress = function(f) {
      var progress = 0;
      if(f.progress.original) {
        progress += f.progress.original;
      };
      // if the file is an image, sum the progress of other file sizes
      if (f.file.type.indexOf("image") > -1) {
        for (i=0; i<$scope.imageSizes.length; i++) {
          
          // add the additional file sizes to the progress measure 
          var filesize = $scope.imageSizes[i].filesize;
          if (filesize != "original") {
            var sizeProgress = f.progress[filesize];
            if (sizeProgress) {
              progress += sizeProgress;
            };
          }
        };
        return (progress/4);
      } else { 
        return progress;
      };
    }; // closes getProgress


    // function to call when user drags file onto screen
    $scope.$watch('draggedFiles', function () {
      if ($scope.draggedFiles) {
        uploadAllFiles($scope.draggedFiles);
      }
    });

    // function to call when user selects files with the Browse button
    $scope.$watch('browsedFiles', function () {
      if ($scope.browsedFiles) {
        uploadAllFiles($scope.browsedFiles);
      }
    });

  }
]);



// provide a filter we can use to trust resources requested from aws
VoicesApp.filter('trusted', [
      "$sce", 
  function ($sce) {
  return function(url) {
    return $sce.trustAsResourceUrl(url);
  };
}]);



// this controller allows us to display record attachments
// and requires a close method 
VoicesApp.controller('ModalController', [
    "$scope", "$http", "$element", "close", "attachment", "saveAnnotationService",
  function($scope, $http, $element, close, attachment, saveAnnotationService) {
    
    // make the attachment available to the view
    $scope.attachment = attachment;

    // close the modal with a 500 ms fade
    $scope.close = function(result) {
      // because we use bootstrap, manually hide the backdrop
      $element.modal('hide');

      // then close the modal, sending the attachmentId back to the function
      // that called the modal
      close(result, 500); 
    }; 

    // function that allows users to save annotation to db
    $scope.saveAnnotation = function(annotation, attachmentId) {
      // call the saveAnnotation service
      saveAnnotationService.saveAnnotation(annotation, attachmentId);
    };


    // function that informs client whether a file has a placeholder image
    var hasPlaceholderImage = function(attachment) {
      if (attachment.placeholder_image_path !== null) {
        return attachment.placeholder_image_path;
      } else { 
        return false; 
      };
    };
    

    // function to determine which image url to serve to the client
    $scope.getImageUrl = function(attachment) {
      var placeholderPath = hasPlaceholderImage(attachment);
      if (placeholderPath) {
        return placeholderPath;
      } else {
        
        var assetPath = attachment.medium_image_url.replace("/medium/","/annotation_thumb/");
        
        // if the upload is a video file, return the image asset, not the video file
        if (attachment.media_type == "video") {
          // replace the user-provided filetype with the image filetype we persist in the db
          var splitUserFileName = attachment.file_upload_file_name.split(".");
          var userFileType = splitUserFileName[splitUserFileName.length - 1];
          return assetPath.replace(userFileType, "jpg");
        
        } else {
          return assetPath;
        }

      }; // closes else clause for attachments without placeholderpath
    }; // closes getImageUrl
  } // closes controller function
]);





VoicesApp.controller("GalleryController", [
        "$scope", "$http", "$location", "ModalService", "saveAnnotationService", "pageClassService",
  function($scope, $http, $location, ModalService, saveAnnotationService, pageClassService) {
    var self = this;

    // always start user on page 0
    $scope.currentPage = 0

    // global value that determines how many attachments a record needs before we
    // break into the superuser pagination
    $scope.superUserBreakpoint = 20;

    // create an array in which we'll store attachments that shouldn't be shown
    $scope.hiddenAttachments = [];

    // array of elements over which user is hovering
    $scope.hoveredAttachments = [];
    
    $scope.getRecordId = function() {
      
      // on page load, parse the requested record and page number from the params
      var url = window.location.href;
      
      // to keep the code dry, use controller for record#show, record#annotate
      // and record#edit so parse url accordingly. First remove trailing edit from url
      if (url.indexOf("/edit") > -1) {
        url = url.replace("/edit", "");
      }
      // then parse the record id
      if (url.indexOf("/records/") > -1) {
        $scope.recordId = Number( url.split("records/")[1].split("?")[0].split(".")[0] );
      } 
      if (url.indexOf("/annotate/") > -1) {
        $scope.recordId = Number( url.split("annotate/")[1].split("?")[0].split(".")[0] );
      }
    
      // once the recordId is available, fetch json detailing the record and its attachments
      $scope.getAttachments($scope.recordId, $scope.currentPage);
    };


    $scope.setAttachmentsPerPage = function() {
      var url = window.location.href;

      // the gallery view should hold 20 images per page for all views except annotate, iff
      // there are more than n attachments for the record 
      if (url.indexOf("/annotate") > -1) {
        // if the user has only one record, push 1 attachment per page to client
        // nb: this should never happen through normal operations, as users are only
        // requested to annotate a record's annotations if that record has > 4 attachments,
        // but if a user requests ROOTURL/annotate/Record-with-1-attachment-id, 
        // we want to serve them with a nice looking page
        if ($scope.data.attachments.length == 1) {
          $scope.attachmentsPerPage = 1;
        } else { $scope.attachmentsPerPage = 4; }
      }

      if ($scope.data.attachments.length > $scope.superUserBreakpoint) {
        $scope.attachmentsPerPage = $scope.attachmentsPerPage ? $scope.attachmentsPerPage : 20;
      }

      // use ternary operator to finalize attachments per page
      $scope.attachmentsPerPage = $scope.attachmentsPerPage ? $scope.attachmentsPerPage : 4;
      
      // store the initial attachmentsPerPage for restoring attachmentsPerPage on view toggle
      $scope.initialAttachmentsPerPage = $scope.attachmentsPerPage;
    };


    // set the number of pages for the current record
    $scope.setTotalNumberOfPages = function() {
      // subtract one to account for 0 based indexing
      $scope.totalNumberOfPages = Math.ceil( $scope.data.attachments.length / $scope.attachmentsPerPage );
    };


    // returns json with 'record' and 'attachments' keys
    // the value of the attachment key is an array of attachments,
    // each of which is a hashtable
    $scope.getAttachments = function(recordId, pageToFetch) {
      if (recordId) {
          $http.get("/records/" + recordId + ".json")
        .then(function(response) {
          // on success
          $scope.data = response.data;

          // use the data to set the attachments per page
          $scope.setAttachmentsPerPage();

          // fetch the first page of results
          $scope.getPageOfAttachments(pageToFetch);

          // call function to make total number of pages available to functions
          $scope.setTotalNumberOfPages()

        }, // on failure
          function(response) {
            console.log("http request failed", response.status);
          }
        )
      } 
    };


    // function that informs client whether a file has a placeholder image
    $scope.hasPlaceholderImage = function(attachment) {
      if (attachment.placeholder_image_path !== null) {
        return attachment.placeholder_image_path;
      } else { 
        return false; 
      };
    };

    // function to determine which image url to serve to the client
    $scope.getImageUrl = function(attachment) {
      var placeholderPath = $scope.hasPlaceholderImage(attachment);
      if (placeholderPath) {
        return placeholderPath;
      } else {
        var assetPath = '';
        if ($scope.attachmentsPerPage == 1) {
          var assetPath = attachment.medium_image_url;
        }
        if ($scope.attachmentsPerPage == 4) {
          var assetPath = attachment.annotation_thumb_url;
        }
        if ($scope.attachmentsPerPage == 20) {
          var assetPath = attachment.square_thumb_url;
        }
        
        return assetPath;

      }; // closes else
    }; // closes function

    
    // function to provide image file name for alt tag
    $scope.getFileName = function(attachment) {
      return attachment.file_upload_url.split('/').pop().split('?')[0];
    };


    // function to include moused over attachment in array of hovered attachments
    $scope.addHoveredAttachment = function(attachment) {
      $scope.hoveredAttachments.push(attachment);
    };


    // function to remove moused out attachment from array of hovered attachments
    $scope.removeHoveredAttachment = function(attachment) {
      var indexOfAttachment = $scope.hoveredAttachments.indexOf(attachment);
      $scope.hoveredAttachments.splice(indexOfAttachment, 1);
    };


    // function that returns all attachments on a aparticular page 
    // of a record, and updates the current page in scope to the retrieved
    // page
    $scope.getPageOfAttachments = function(pageNumber) {
      // from the full array of attachments, select the range between
      // attachmentsPerPage * currentPage and attachmentsPerPage * (currentPage + 1)
      var startingAttachmentIndex = $scope.attachmentsPerPage * pageNumber;
      var endingAttachmentIndex = $scope.attachmentsPerPage * (pageNumber + 1);

      $scope.attachmentsOnCurrentPage = $scope.data.attachments.slice(
        startingAttachmentIndex, endingAttachmentIndex
      ); 

      // update the current page in the scope
      $scope.currentPage = pageNumber;
    };


    // build up an array of page numbers [= xrange(nPages)]
    $scope.getPageArray = function(numberOfPages) {
      return new Array(numberOfPages);
    };


    // functions to send users to the {previous, next} page
    $scope.previousPage = function() {
      if ($scope.currentPage > 0) {
        $scope.currentPage = $scope.currentPage - 1;
      }
      $scope.getPageOfAttachments($scope.currentPage);
    }


    $scope.nextPage = function() {
      if ($scope.currentPage < $scope.totalNumberOfPages) {
        $scope.currentPage = $scope.currentPage + 1;
      }
      $scope.getPageOfAttachments($scope.currentPage);
    }


    // function that allows users to save annotation to db
    $scope.saveAnnotation = function(annotation, attachmentId) {
      
      // call the saveAnnotation service
      saveAnnotationService.saveAnnotation(annotation, attachmentId);
    };


    $scope.multipleRecordViewClicked = function() {
      // toggle the view buttons
      $scope.multipleRecordView = true;

      // determine the number of attachments per page
      $scope.attachmentsPerPage = $scope.initialAttachmentsPerPage;

      // reset the total number of pages
      $scope.setTotalNumberOfPages();

      // restore the 0th page of attachments
      $scope.getPageOfAttachments(0);
    };


    $scope.singleRecordViewClicked = function() {
      $scope.multipleRecordView = false;
      
      // reset records per page to 1, broadcast the new number of pages
      // to the view, and start users on the 0th page 
      $scope.attachmentsPerPage = 1;
      $scope.setTotalNumberOfPages();
      $scope.getPageOfAttachments(0);
    };



    // on record#edit, allow users to delete an attachment on click of button
    $scope.deleteAttachment = function(attachmentId) {
      // add the attachmentId to the array in the hidden attachment service 
      $scope.hiddenAttachments.push(attachmentId);

      // place the delete request to destroy this attachment
      $.ajax({ url: "/record_attachments/" + attachmentId,
        type: 'DELETE',
        beforeSend: function(xhr) {xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))},
        data: {},
        success: function(response) {
          
          // to fetch new data we need to update $scope.data
          // so call getAttachments
          $scope.getAttachments($scope.recordId, $scope.currentPage);

          // if the delete succeeded, fetch new attachments
          $scope.getPageOfAttachments($scope.currentPage);
        }
      });
    };


    $scope.showAttachmentModal = function(attachment) {

      /***
      * templateUrl: the template to be rendered (this is inlined)
      * controller: the controller that will handle the modal
      * inputs: data to be passed to the specified controller
      *         attachment here is a full attachment json object
      ***/
                    
      ModalService.showModal({
        templateUrl: "attachmentModal.html",
        controller: "ModalController",
        inputs: {
          attachment: attachment
        }
      }).then(function(modal) {  // success callback

        // the modal is a bootstrap element, so we can use the modal() method to show it
        modal.element.modal();
        modal.close.then(function(result) {
          
          // if the modal returned a value, that value
          // represents the id of an attachment that should 
          // be deleted --> pass the result as an input to 
          // delete the recordattachment
          $scope.deleteAttachment(result);

        });
      });
    };


    // initialize the function chain
    $scope.getRecordId();

    // make the current page available to client
    $scope.currentPageClass = pageClassService.getPageClass();

    // initialize the view with multi-record view
    $scope.multipleRecordView = true;

  }
]);






VoicesApp.controller("userController", [
        "$scope", "$http", "$timeout",
    function($scope, $http, $timeout) {
      
    /***
    * Helper functions to provide client with path to asset image
    ***/

    // function that informs client whether a file has a placeholder image
    $scope.hasPlaceholderImage = function(attachment) {
      if (attachment.placeholder_image_path !== null) {
        return attachment.placeholder_image_path;
      } else { 
        return false; 
      };
    };


    // function to determine which image url to serve to the client
    $scope.getImageUrl = function(attachment) {
      var placeholderPath = $scope.hasPlaceholderImage(attachment);
      if (placeholderPath) {
        return placeholderPath;
      } else {
        return attachment.medium_image_url;
      }; // closes else
    }; // closes function



    /***
    * Search functionality 
    ***/

    // define and call function to serve all user records
    var getAllRecords = function() {
      $http.get("/user/show.json", 
        {"params": 
          {"viewAll": $scope.viewAll,
           "sortMethod": $scope.sortMethod
         }, cache: true } 
      ).then(function(response) {
        $scope.records = response.data;
      }, function(response) {
        console.log(response.status);
      }
    )};

    // define function that places get request with user-specified query
    // when user interacts with the search input field
    $scope.search = function(searchTerm) {
        // if the user deletes all text in the input,
        // restore all their records by setting the userRanSearch
        // value back to 0
        if (searchTerm) {
            $scope.userRanSearch = 1;
            $http.get("/user/show.json",
              {"params": 
                {"keywords": searchTerm,
                 "viewAll": $scope.viewAll,
                 "sortMethod": $scope.sortMethod
               }, cache: true }  
            ).then(function(response) {
              $scope.records = response.data;

            }, function(response) {
              console.log(response.status);
            }
          );
      } else {
        getAllRecords();
      };
    } // closes $scope.search()

    // initialize a variable that keeps track of whether a user has run a search
    $scope.userRanSearch = 0;

    
    /***
    * Tab functionality 
    ***/

    // when user clicks a tab, pass a val {0,1}
    // if that val is not identical to the current
    // value of showAllRecords, create a new get request
    // for the appropriate records
    $scope.toggleViewAll = function(val) {
      if (val != $scope.viewAll) {
        $scope.viewAll = val;
        $scope.search($scope.keywords);
      };
    }

    // create a boolean that controls whether we're
    // showing all submissions or only the user's submissions
    // initialize to 1
    $scope.viewAll = 1;


    /***
    * Sort by functionality
    ***/

    // create an array of options users can select to change sort order
    // of search results
    $scope.sortOptions = [
      {"label": "Title", "val": "title"},
      {"label": "Date of Event", "val": "date"},
      {"label": "Date submitted", "val": "created_at"},
      {"label": "Contributor", "val": "cas_user_name"},
      {"label": "Source Url", "val": "source_url"},
      {"label": "Location", "val": "location"}
    ];

    $scope.setSortMethod = function() {
      $scope.requestedSortMethod = $scope.sortOption.val;

      // if the requested sort method != current sort method
      // run a new request for the user
      if ($scope.requestedSortMethod != $scope.sortMethod) {
        $scope.sortMethod = $scope.requestedSortMethod;
        $scope.search($scope.keywords);
      }

    };

    // initialize the page with sort by date
    $scope.sortMethod = $scope.sortOptions[0].val;


    /***
    * Initialize search results 
    ***/

    // initialize the page with all records available to user
    getAllRecords();


  }]
);
