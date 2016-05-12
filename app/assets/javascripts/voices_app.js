// compile all required controllers into one app to expose to views
var VoicesApp = angular.module('VoicesApp', ['ngFileUpload', 'uiSwitch', 'angularModalService']);



// directive that listens for changes to the file upload button
VoicesApp.directive('onFileInputChange', function() {
  return {
    restrict: 'A',
    link: function (scope, element, attrs) {
      var onChangeHandler = scope.$eval(attrs.onFileInputChange);
      element.bind('change', onChangeHandler);
    }
  };
});





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

      // manually build up form. nb. cas username is set by the controller
      var fd = new FormData();
      fd.append('record[title]', form.title );
      fd.append('record[make_private]', form.make_private );
      fd.append('record[description]', form.description );
      fd.append('record[hashtag]', form.hashtag );
      fd.append('record[release_checked]', form.release_checked );

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


    // define the array to which we'll append all user uploaded files
    // and the array in which we'll store the files for which we've received
    // success or error messages from the server
    $scope.filesToSend = [];
    $scope.filesSent = [];

    // create empty form
    $scope.form = {};

    // initialize privacy settings to keep records private
    $scope.form.make_private = $scope.form.make_private? $scope.form.make_private: true;

    // transmit page class so we can distinguish between record#new and record#edit forms
    $scope.currentPageClass = pageClassService.getPageClass();

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

    // specify the url endpoint to which we'll submit the files
    var uploadUrl = "/record_attachments";

    // retrieve the CSRF token to we can make the POST request without getting 422'd
    var csrfToken = $('meta[name="csrf-token"]').attr('content');

    // function called by button click and drag and drop behavior to
    // upload files to server
    var requestFileUpload = function(file) {

      if ($scope.recordId) {
          var formData = {"file_upload": file, 
                 "file_upload[record_id]": $scope.recordId, 
                 "file": "in file_upload"}
        } else {
          var formData = {"file_upload": file, 
                 "file": "in file_upload"}
        };

      file.upload = Upload.upload({
        url: uploadUrl,
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

      file.upload.then(function (resp) {
            // log the success then store the fact we received a response for this file
            console.log('Success ' + resp.config.data.file_upload.name + 'uploaded. Response: ' + resp.data);
            $scope.filesSent.push(resp.config.data.file_upload.name);

        }, function (resp) {
            // log the error then store the fact that we received a response for this file
            console.log('Error status: ' + resp.status);
            $scope.filesSent.push(resp.config.data.file_upload.name);

        }, function (evt) {
            // tie a progress value to this file; Math.min fixes an IE bug (otherwise progress can go to 200%)
            file.progress = Math.min(100, parseInt(100.0 * evt.loaded / evt.total));
      });

    
      // expose function that allows user to cancel the upload of a file
      $scope.abort = function(file) {
        console.log("abort requested", file);
        file.upload.abort();
      };

    }; // closes requestFileUpload();


    // expose function that cancels all pending user uploads
    $scope.cancelAll = function() {
      for (i=0; i < $scope.filesToSend.length; i++) {
        $scope.abort($scope.filesToSend[i]);
      }
    };

    
    var uploadAllFiles = function(files) {
      // iterate over files, upload and set progress bar for each
      for (i=0; i < files.length; i++)  {
        // append the file to our array of files to send
        $scope.filesToSend.push(files[i]);

        // request that this file be uploaded
        var fileToUpload = files[i];
        requestFileUpload(fileToUpload);
      }; // closes file upload for loop
    }
    

    // fire call when user interacts with file upload button
    $scope.uploadFiles = function(event){
      // files = all files the user selected on button click
      var files = event.target.files;

      console.log(files);

      uploadAllFiles(files);
    }; // closes uploadFiles function
    

    // when user drags file onto screen, call function
    $scope.$watch('draggedFiles', function () {
      if ($scope.draggedFiles) {
        console.log("user dragged", $scope.draggedFiles);

        uploadAllFiles($scope.draggedFiles);
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

  }
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

      console.log("maximum attachments per page is", $scope.attachmentsPerPage);
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
      console.log("getting attachments");

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


    // function to determine which image url to serve to the client
    $scope.getImageUrl = function(attachment) {
      if ($scope.attachmentsPerPage == 1) {
        return attachment.medium_image_url;
      }
      if ($scope.attachmentsPerPage == 4) {
        return attachment.annotation_thumb_url;
      }
      if ($scope.attachmentsPerPage == 20) {
        return attachment.square_thumb_url;
      }
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
      console.log("requested page", pageNumber);

      // from the full array of attachments, select the range between
      // attachmentsPerPage * currentPage and attachmentsPerPage * (currentPage + 1)
      var startingAttachmentIndex = $scope.attachmentsPerPage * pageNumber;
      var endingAttachmentIndex = $scope.attachmentsPerPage * (pageNumber + 1);

      $scope.attachmentsOnCurrentPage = $scope.data.attachments.slice(
        startingAttachmentIndex, endingAttachmentIndex
      ); 

      // update the current page in the scope
      $scope.currentPage = pageNumber;

      console.log("current attachments:", $scope.attachmentsOnCurrentPage, "current page:", $scope.currentPage);
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

      console.log("multiple records clicked", $scope.attachmentsPerPage);
    };


    $scope.singleRecordViewClicked = function() {
      $scope.multipleRecordView = false;
      
      // set things so that we can only have one record per page
      // and start us off on the 0th page
      $scope.attachmentsPerPage = 1;

      // reset the total number of pages
      $scope.setTotalNumberOfPages();

      $scope.getPageOfAttachments(0);

      console.log("single record clicked", $scope.attachmentsPerPage);
    };



    // on record#edit, allow users to delete an attachment on click of button
    $scope.deleteAttachment = function(attachmentId) {
      console.log("called delete attachment", attachmentId);

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
      var self = this;

      // variable to set the index of the attachment that should be shown
      $scope.displayIndex = 0;

      // variable that indicates the index of the image to display
      var incrementDisplayIndex = function() {
        // increment the counter, then call the function again with a timeout
        $scope.displayIndex++;        
        $timeout(incrementDisplayIndex, 2000);
      };

      // initialize the function below to allow the displayIndex to change
      //incrementDisplayIndex();

      // retreives an array of hashes, each of which has record and attachment keys
      var getUserRecords = function() {
        $http.get( "/user/show.json", {cache: true} )
        .then(function(response) {
          $scope.userRecords = response.data;
        }, function(response) {
          console.log(response.status);
        }
      )};

      getUserRecords();

      // initialize a variable that keeps track of whether a user has run a search
      $scope.userRanSearch = 0;

      // define and call function to serve all user records
      var allUserRecords = function() {
        $http.get("/user/show.json", {cache: true})
        .then(function(response) {
          $scope.records = response.data;
        }, function(response) {
          console.log(response.status);
        }
      )};

      allUserRecords();

      
      // define function that places get request with user-specified query
      // when user interacts with the search input field
      $scope.search = function(searchTerm) {
        // if the user deletes all text in the input,
        // restore all their records by setting the userRanSearch
        // value back to 0
        if (searchTerm) {
            $scope.userRanSearch = 1;
            $http.get("/user/show.json",
              {"params": {"keywords": searchTerm}, cache: true }  
            ).then(function(response) {
              $scope.records = response.data;

            }, function(response) {
              console.log(response.status);
            }
          );
      } else {
        allUserRecords();
      };
    }
  }]
);
