// compile all required controllers into one app to expose to views
var VoicesApp = angular.module('VoicesApp', ['ngFileUpload', 'uiSwitch']);

VoicesApp.directive('onFileInputChange', function() {
  return {
    restrict: 'A',
    link: function (scope, element, attrs) {
      var onChangeHandler = scope.$eval(attrs.onFileInputChange);
      element.bind('change', onChangeHandler);
    }
  };
});


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
      fd.append('record[include_name]', form.include_name );
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



VoicesApp.controller("FormController", [
        "$scope", "$http", "$location", "Upload", "postRecordForm",
  function($scope, $http, $location, Upload, postRecordForm ) {

    // define the array to which we'll append all user uploaded files
    // and the array in which we'll store the files for which we've received
    // success or error messages from the server
    $scope.filesToSend = [];
    $scope.filesSent = [];

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
    // including the boolean slider be tied to the form element

    // fire call when user interacts with file upload
    $scope.uploadFiles = function(event){

      // specify the function we'll call to upload files
      var requestFileUpload = function(file) {

        if ($scope.recordId) {
            var formData = {"file_upload": file, 
                   "file_upload[record_id]": $scope.recordId, 
                   "file": "in file_upload"}
          } else {
            var formData = {"file_upload": file, 
                   "file": "in file_upload"}
          };

        $scope.upload = Upload.upload({
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
        }).then(function (resp) {
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
      };

      // specify the url endpoint to which we'll submit the files
      var uploadUrl = "/record_attachments";

      // retrieve the CSRF token to we can make the POST request without getting 422'd
      var csrfToken = $('meta[name="csrf-token"]').attr('content');

      // files = all files the user selected on button click
      var files = event.target.files;

      // iterate over files, upload and set progress bar for each
      for (i=0; i < files.length; i++)  {
        // append the file to our array of files to send
        $scope.filesToSend.push(files[i]);

        // request that this file be uploaded
        var fileToUpload = files[i];
        requestFileUpload(fileToUpload);
      }; // closes file upload for loop
    }; // closes uploadFiles function
    
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



VoicesApp.controller("GalleryController", [
        "$scope", "$http", "$location",
  function($scope, $http, $location) {
    var self = this;

    // always start user on page 0
    $scope.currentPage = 0

    // global value that determines how many attachments a record needs before we
    // break into the superuser pagination
    $scope.superUserBreakpoint = 20;

    // array of elements to hide (in case user deletes attachment)
    $scope.hiddenAttachments = [];
    
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


    // function to expose the current site to the client
    $scope.getCurrentPageClass = function() {
      var url = window.location.href;
      if (url.indexOf("/edit") > -1) {
        $scope.currentPageClass = "edit";
      }
      if (url.indexOf("/annotate") > -1) {
        $scope.currentPageClass = "annotate";
      }
    };


    $scope.setAttachmentsPerPage = function() {
      var url = window.location.href;

      // the gallery view should hold 20 images per page for all views except annotate, iff
      // there are more than n attachments for the record 
      if (url.indexOf("/annotate") > -1) {
        $scope.attachmentsPerPage = 4;
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
    $scope.getAttachments = function(recordId) {
      console.log("getting attachments");

      if (recordId) {
          $http.get("/records/" + recordId + ".json")
        .then(function(response) {
          // on success
          $scope.data = response.data;

          // use the data to set the attachments per page
          $scope.setAttachmentsPerPage();

          // fetch the first page of results
          $scope.getPageOfAttachments(0);

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


    // save user annotations (send CSRF token for security)
    $scope.saveAnnotation = function(userAnnotation, attachmentId) {      
      $.ajax({ url: "/record_attachments/" + attachmentId + ".json",
        type: 'PUT',
        beforeSend: function(xhr) {xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))},
        data: {"annotation": userAnnotation},
        success: function(response) {}
      });
    };


    // on record#edit, allow users to delete an attachment on click of button
    $scope.deleteAttachment = function(attachmentId) {
      // add the attachment id to the array of attachments to hide
      $scope.hiddenAttachments.push(attachmentId);

      $.ajax({ url: "/record_attachments/" + attachmentId,
        type: 'DELETE',
        beforeSend: function(xhr) {xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))},
        data: {},
        success: function(response) {}
      });
    }


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

    // initialize the function chain
    $scope.getRecordId();

    // call an additional function to make current page available to client
    $scope.getCurrentPageClass();

    // initialize the view with multi-record view
    $scope.multipleRecordView = true;


  }
]);



VoicesApp.controller("recordSearchController", [
        "$scope", "$http",
      function($scope, $http) {
        var self = this;
        
        // initialize a variable that keeps track of whether a user has run a search
        $scope.userRanSearch = 0;

        // define and call function to serve all user records
        var allUserRecords = function() {
          $http.get("/user/show.json")
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
                {"params": {"keywords": searchTerm} }  
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
    }
  ]
);



VoicesApp.controller("userController", [
        "$scope", "$http",
    function($scope, $http) {
      var self = this;

      // retreives an array of hashes, each of which has record and attachment keys
      var getUserRecords = function() {
        $http.get("/user/show.json")
        .then(function(response) {
          $scope.userRecords = response.data;
        }, function(response) {
          console.log(response.status);
        }
      )};

      getUserRecords();

    }
  ]
);
