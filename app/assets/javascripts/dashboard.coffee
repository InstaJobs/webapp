do ->
	app = angular.module 'instajob', [ 'ngProgressLite', 'templates', 'ui.router', 'uiGmapgoogle-maps', 'ui.slider', 'ngFileUpload'];
	app.config ['$httpProvider', '$stateProvider', '$urlRouterProvider', ($httpProvider, $stateProvider, $urlRouterProvider) -> 
    $httpProvider.defaults.headers.common['X-CSRF-Token'] = $('meta[name=csrf-token]').attr('content');
    return
  ];
 app.config ['$stateProvider', '$urlRouterProvider', '$locationProvider', ($stateProvider, $urlRouterProvider, $locationProvider) ->
  	$urlRouterProvider.otherwise('/dashboard');
  	$stateProvider.state 'jobs', {
  		url: '/dashboard/alljobs',
  		templateUrl: 'jobs.html',
  		controller: 'jobsCtrl',
  		resolve: {
  			jobs: ["$http", ($http) ->
  				return $http.get('/api/jobs').then (response) ->
  					return response.data;
  			]
  		}
  	};
    
   $stateProvider.state 'postjob', {
      url: '/dashboard/postjob',
      templateUrl: 'postjob.html',
      controller: 'postJobCtrl',
      resolve:{
        myjobs: ["$http", ($http) -> 
          return $http({ url : '/api/jobs', method : 'GET', params: {user_id : true}}).then (response) ->
            return response.data.jobs;
        ],
        mycompanies: ["$http", ($http) -> 
          return $http({url: '/api/companies', method : 'GET', params: {user_id : true}}).then (response) ->
            return response.data;
        ]
      }
    };
    
   $stateProvider.state 'jobsnear', {
      url: '/dashboard',
      templateUrl: 'jobsnear.html',
      controller: 'jobsNearCtrl',
    };
   
   $stateProvider.state 'job', {
      url: '/dashboard/job/:jobid',
      templateUrl: 'job.html',
      controller: 'jobCtrl',
      resolve: {
        job: ["$http", "$stateParams", ($http, $stateParams) -> 
          
        ]
      }
    };
   $stateProvider.state 'logout', {
      url: '/logout',
      controller : ['$http', '$location', '$window', ($http, $location, $window) -> 
        $http.get('/logout').then (response) ->
          if response.data.result == "success"
            $window.location.href = "/";
      ]
    };
   $stateProvider.state 'candidates', {
      url: '/dashboard/candidates/:jobid',
      templateUrl: 'candidates.html',
      controller: 'candidatesCtrl',
      resolve: {
        candidates: ["$http", "$stateParams", ($http, $stateParams) ->
          return $http({url: '/api/candidates', method : "GET", params: {jobid : $stateParams["jobid"]}}).then (response) ->
            return response.data;
        ],
        matchedusers : ["$http", "$stateParams", ($http, $stateParams) ->
          return $http({url: '/api/matchedusers', method : "GET", params: {jobid : $stateParams["jobid"]}}).then (response) ->
            return response.data;
        ],
        job: ["$http", "$stateParams", ($http, $stateParams) -> 
          return $http.get('/api/jobs/'+$stateParams["jobid"]).then (response) ->
            return response.data;
        ]
      }
    };

   $stateProvider.state 'matches', {
      url: '/dashboard/matches',
      templateUrl: 'matches.html',
      controller: 'matchesCtrl',
      resolve: {
        matches: ["$http", ($http) ->
          return $http.get('/api/mymatches').then (response) ->
            return response.data;
        ]
      }
    };

   $stateProvider.state 'profile', {
      url: '/dashboard/profile',
      templateUrl: 'profile.html',
      controller: 'profileCtrl',
      resolve: {
        user: ["$http", ($http) ->
          return $http.get('/api/user').then (response) ->
            return response.data;
        ]
      }
    };
   $stateProvider.state 'profile.edit', {
      url: '/edit',
      templateUrl: 'profile_edit.html',
      controller: 'profileEditCtrl',
    };
   $stateProvider.state 'profile.password', {
      url: '/password',
      templateUrl: 'profile_pass.html',
      controller: 'profilePasswordCtrl',
    };
   $stateProvider.state 'savedjobs', {
      url: '/dashboard/savedjobs',
      templateUrl: 'savedjobs.html',
      controller: 'savedjobsCtrl',
      resolve: {
        savedjobs: ["$http", ($http) ->
          return $http.get('/api/savedjobs').then (response) ->
            return response.data; 
        ]
      }  
    };
   $locationProvider.html5Mode({
      enabled: true,
      requireBase: false
    });
  ];
	return