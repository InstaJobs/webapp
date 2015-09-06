do ->
	app = angular.module 'instajob'
	app.controller 'profileEditCtrl', ["$http", "$timeout", "$scope", "$rootScope", 'Upload', ($http, $timeout, $scope, $rootScope, Upload) ->
		$scope.avataruploadbtnval = "Upload new avatar";
		$scope.message = null;
		$scope.$watch('file', () ->
			$scope.upload($scope.file);
		);
		$scope.upload = (file) ->
			if file
				$scope.avataruploadbtnval = "Uploading ...";
				Upload.upload({
					url: '/api/uploadpropic',
					file: file	
				}).progress((evt) -> 
					progressPercentage = parseInt(100.0 * evt.loaded / evt.total);
					console.log('progress: '+progressPercentage+" % "+ evt.config.file.name);
				).success((data, status, headers, config) ->
					updatePropic();
					console.log('file '+config.file.name + 'uploaded. Response:'+data);
				).error((data, status, headers, config) ->
					console.log("Error");
				)
		updatePropic = () ->
			$timeout(checkStat, 1000);
		checkStat = () ->
			$http.get('/api/uploadstat').then (response) -> 
				if(response.data.result == false)
					$scope.avataruploadbtnval = "Upload new avatar";
					$rootScope.user_propic = response.data.url
					$rootScope.user_thumb = response.data.thumburl
				else
					updatePropic()

		$scope.update = (user) ->
			$http({url: '/api/user', method: "POST", data: user}).then (response) ->
				if(response.data.result == "success")
					$scope.message = "Profile Updated";
					$('#myModal').modal();
				else
					$scope.message = response.data.result;
					$('#myModal').modal();
		return 
	]
	return