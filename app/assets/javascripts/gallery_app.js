// identify ngRoute as a dependency of this module
var GalleryApp = angular.module('GalleryApp', []);
  

GalleryApp.controller("GalleryController", [
        "$scope", "$http", "$location",
  function($scope, $http, $location) {
    var self = this;

    // on page load, parse the requested record and page number from the params
    var url = window.location.href;
    var recordId = Number( url.split("records/")[1].split(".")[0] );
    var pageNumber = 0

    // save the recordId for future requests
    $scope.recordId = recordId;

    // if user interacts with navigation, serve new attachments
    $scope.fetchAttachments = function(recordId, pageNumber) {
      if (recordId) {
          $http.get("/records/" + recordId + ".json" + "?page=" + pageNumber)
        .then(function(response) {
          // on success
          $scope.data = response.data;
          $scope.current_page = pageNumber;
          console.log($scope.data, pageNumber);

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
      if ($scope.current_page > 0) {
        $scope.current_page = $scope.current_page - 1;
      }
      $scope.fetchAttachments(recordId, $scope.current_page);
    }

    $scope.nextPage = function() {
      if ($scope.current_page < $scope.data.number_of_pages) {
        $scope.current_page = $scope.current_page + 1;
      }
      $scope.fetchAttachments(recordId, $scope.current_page);
    }


    // initialize page with values from url
    $scope.fetchAttachments(recordId, pageNumber);

  }
]);