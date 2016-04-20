angular.module('recordsApp', [])
  .controller("recordSearchController", [
        "$scope", "$http",
      function($scope, $http) {
        var self = this;
        
        // initialize a variable that keeps track of whether a user has run a search
        $scope.userRanSearch = 0;

        // define and call function to serve all user records
        $scope.allUserRecords = function() {
          $http.get("/user/show.json")
          .then(function(response) {
            $scope.allUserRecords = response.data;
          }, function(response) {
            console.log(response.status);
          }
        )};
        $scope.allUserRecords();

        // define function that places get request with user-specified query
        // when user interacts with the search input field
        $scope.records = [];
        $scope.search = function(searchTerm) {
          $scope.userRanSearch = 1;
          $http.get("/user/show.json",
            {"params": {"keywords": searchTerm} }  
          ).then(function(response) {
            $scope.records = response.data;
          }, function(response) {
            console.log(response.status);
          }
        );
      }
    }
  ]
);