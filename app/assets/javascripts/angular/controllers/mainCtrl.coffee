do ->
	app = angular.module 'instajob'
	app.controller 'mainCtrl', ["$scope", "$rootScope", "ngProgressLite", ($scope, $rootScope, ngProgressLite) ->
		uname = document.getElementById('username').innerHTML;
		$rootScope.user_name = uname; 
		ujcount = document.getElementById('userjobsc').innerHTML;
		$rootScope.user_jobcount = ujcount;
		matches = document.getElementById('userjobm').innerHTML;
		$rootScope.user_jobmatch = matches;
		propic = document.getElementById('propic').innerHTML;
		$rootScope.user_propic = propic;
		thumb = document.getElementById('thumb').innerHTML;
		$rootScope.user_thumb = thumb;
		email = document.getElementById('email').innerHTML;
		$rootScope.user_email = email;
		number = document.getElementById('number').innerHTML;
		$rootScope.user_number = parseInt(number);
		$rootScope.$on '$stateChangeStart', (event, toState, toParams, fromState, fromParams) ->
			ngProgressLite.start();
			return
		$rootScope.$on '$stateChangeSuccess', (event, toState, toParams, fromState, fromParams) ->
      ngProgressLite.done();
      return
	]
	return