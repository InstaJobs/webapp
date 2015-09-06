do ->
	app = angular.module 'instajob'
	app.controller 'profilePasswordCtrl', ["$http", "$timeout", "$scope", ($http, $timeout, $scope) ->
		$scope.message = null;
		$scope.update = (user) ->
			if(user.newpassword != user.renewpassword)
				alert("New Passwords do not match.")
				return
			$http({url: '/api/user', method: "POST", data: user}).then (response) ->
				if(response.data.result == "success")
					$scope.message = "Updated Password";
					$('#myModal').modal();
				else
					$scope.message = response.data.result;
					$('#myModal').modal();
		return 
	]
	return