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
    $scope.fetchAttachments = function(recordId) {
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
    $scope.fetchAttachments($scope.recordId);

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

    // define an empty array of elements to hide, add to this list if user deletes an attachment
    $scope.hiddenAttachments = [];
    
    $scope.fetchRecordId = function() {
      
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

      // once the recordId is available, initialize the page
      $scope.fetchAttachments($scope.recordId, $scope.currentPage);

    };

    // if user interacts with navigation, serve new attachments
    $scope.fetchAttachments = function(recordId, pageNumber) {
      if (recordId) {
          $http.get("/records/" + recordId + ".json" + "?page=" + pageNumber)
        .then(function(response) {
          // on success
          $scope.data = response.data;
          $scope.currentPage = pageNumber;
          
        }, // on failure
          function(response) {
            console.log("http request failed", response.status);
          }
        )
      } 
    };

    // build up an array of page numbers
    $scope.pageArray = function(numberOfPages) {
      return new Array(numberOfPages);
    };

    // functions to send users to the {previous, next} page
    $scope.previousPage = function() {
      if ($scope.currentPage > 0) {
        $scope.currentPage = $scope.currentPage - 1;
      }
      $scope.fetchAttachments($scope.recordId, $scope.currentPage);
    }

    $scope.nextPage = function() {
      if ($scope.currentPage < $scope.data.number_of_pages) {
        $scope.currentPage = $scope.currentPage + 1;
      }
      $scope.fetchAttachments($scope.recordId, $scope.currentPage);
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

    // initialize the function chain
    $scope.fetchRecordId();
  
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
