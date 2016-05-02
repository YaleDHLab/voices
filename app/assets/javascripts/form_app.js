var FormApp = angular.module('FormApp', ['ngFileUpload']);

FormApp.directive('onFileInputChange', function() {
  return {
    restrict: 'A',
    link: function (scope, element, attrs) {
      var onChangeHandler = scope.$eval(attrs.onFileInputChange);
      element.bind('change', onChangeHandler);
    }
  };
});



FormApp.service('uploadDispatcher', [
      '$http', 'Upload', 
  function ($http, Upload) {
    this.uploadFileToUrl = function(file, uploadUrl){
      var fd = new FormData();

      // retrieve the CSRF token to we can make the POST request without getting 422'd
      var csrfToken = $('meta[name="csrf-token"]').attr('content');

      // add file to the file_upload key of the record_attachments hash
      fd.append("record_attachment[file_upload]", file);

      $http.post(uploadUrl, fd, {
          transformRequest: angular.identity,
          headers: {
            'Content-Type': undefined,
            'X-CSRF-Token': csrfToken
          }
      })
      .success(function(){
      })
      .error(function(){
      });

    }
  }
]);



FormApp.controller("FormController", [
        "$scope", "$http", "$location", "uploadDispatcher", "Upload" ,
  function($scope, $http, $location, uploadDispatcher, Upload ) {

    // fire call when user interacts with file upload
    $scope.uploadFiles = function(event){

      // files will contain all user selected files
      var files = event.target.files;
      var uploadUrl = "/record_attachments";

      // retrieve the CSRF token to we can make the POST request without getting 422'd
      var csrfToken = $('meta[name="csrf-token"]').attr('content');

      for (i=0; i < files.length; i++)  {
        var fileToUpload = files[i];

        $scope.upload = Upload.upload({
          url: uploadUrl,
          method: 'POST',
          data: {"file_upload": fileToUpload},    //it is the data that's need to be sent along with image
          file: fileToUpload,
          headers: {'X-CSRF-Token': csrfToken},
          fileFormDataName: 'record_attachment[file_upload]',//myEntity is the name of the entity in which image is saved and image is the name of the attachment
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
              console.log('Success ' + resp.config.data.file.name + 'uploaded. Response: ' + resp.data);
          }, function (resp) {
              console.log('Error status: ' + resp.status);
          }, function (evt) {
              var progressPercentage = parseInt(100.0 * evt.loaded / evt.total);
              console.log('progress: ' + progressPercentage + '% ' + evt.config.data.file.name);
        });
      };

      
      // execute the command to actually upload the file
      //uploadDispatcher.uploadFileToUrl(fileToUpload, uploadUrl);
    };
  }
]);