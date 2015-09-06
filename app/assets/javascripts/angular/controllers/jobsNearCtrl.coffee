do ->
	app = angular.module 'instajob'
	app.controller 'jobsNearCtrl', ["$timeout", "$http", "$scope", "uiGmapGoogleMapApi", "$rootScope", "$state", ($timeout, $http, $scope, uiGmapGoogleMapApi, $rootScope, $state) ->
		$scope.loading = true;
		$scope.message = null;
		$scope.lat = null;
		$scope.lng = null;
		$scope.address = null;
		$scope.jobs = null;
		$scope.radius = 50;
		$scope.selectedj = null;
		$scope.mapv = false;
		$scope.infowindowjob = null;
		$scope.mapzoom = 12;
		$scope.alljobs = false;
		$scope.savedjobs = null;

		hidealljobsinfo = () ->
			$scope.alljobs = false;
		getLatLng = () ->
			if(navigator.geolocation)
					navigator.geolocation.getCurrentPosition(showPosition, poserror);
			else
				alert("Browser not supported");

		poserror = (error) ->
			$scope.message = "Unable to get your location. You can search by address. Showing all jobs now."
			$("#info").modal();
			$scope.loading = false;
			$scope.lat = 0;
			$scope.lng = 0;
			$http({url: "/api/jobs", method: "GET"}).then (response) ->
				$scope.loading = false;
				$scope.jobs = response.data.jobs;
				$scope.address = response.data.address;
				if(response.data.all == true)
					$scope.alljobs = true;
				initializeMap();
				$http.get('/api/savedjobs').then (response) ->
					$scope.savedjobs = response.data;
					updateColor()
			return true

		showPosition = (position) ->
			$scope.lat = position.coords.latitude;
			$scope.lng = position.coords.longitude;
			$scope.$apply();
			$http({url: "/api/jobs", method: "GET", params : {lat: $scope.lat, lng: $scope.lng, radius: $scope.radius}}).then (response) ->
				$scope.loading = false;
				$scope.jobs = response.data.jobs;
				$scope.address = response.data.address;
				if(response.data.all == true)
					$scope.alljobs = true;
					# $timeout(hidealljobsinfo, 5000)
				initializeMap();
				$http.get('/api/savedjobs').then (response) ->
					$scope.savedjobs = response.data;
					updateColor()
			return true

		getLatLng();

		initializeMap = () ->
			$scope.map = { center: { latitude: $scope.lat, longitude: $scope.lng }, zoom: $scope.mapzoom };
			$scope.markers = {
				options:{
					icon: "/map-marker-icon.png"
				}
			}
			if $scope.jobs
				for j, index in $scope.jobs
					j.bgcolor = "#0F2938"
					j.idmap = index + 1;
					j.coords = {
						latitude: j.location[0],
						longitude: j.location[1],
					}
					if j.title
						if(j.title.length > 50)
							j.short_title = j.title.substring(0, 50)+".."
						else
							j.short_title = j.title
					if j.description
						if(j.description.length > 140)
							indlast = 140
							while !(j.description.charAt(indlast) == ' ' || j.description.charAt(indlast) == '.')
								indlast++;
								if(indlast >= j.description.length)
									break;
							j.short_description = j.description.substring(0, indlast)+".."
						else
							j.short_description = j.description
					if j.responsibility
						if(j.responsibility.length > 140)
							indlast = 140
							while !(j.responsibility.charAt(indlast) == ' ' || j.responsibility.charAt(indlast) == '.')
								indlast++;
								if(indlast >= j.responsibility.length)
									break;
							j.short_responsibility = j.responsibility.substring(0, indlast)+".."
						else
							j.short_responsibility = j.responsibility
			updateColor()

		$scope.slider = 'options':
		  start: (event, ui) ->
		    # console.log 'he'
		    return
		  stop: (event, ui) ->
		  	$scope.loading = true;
		  	$http({url: "/api/jobs", method: "GET", params : {lat: $scope.lat, lng: $scope.lng, radius: $scope.radius}}).then (response) ->
						$scope.loading = false;
						$scope.jobs = response.data.jobs;
						if(response.data.all == true)
							$scope.alljobs = true;
							# $timeout(hidealljobsinfo, 5000)
						initializeMap();

		$scope.markersEvents = 
			"mouseover" : (gMarker, eventname, model) ->
				$scope.infowindowjob = model;
				$(".infowindow").fadeIn();
			"mouseout" : (gMarker, eventname, model) ->

		$scope.addJob = (job) ->
			$http({url: '/api/addJob', params: {job_id: job.id["$oid"]}}).then (response) ->
				if response.data.result == "success"
					$rootScope.user_jobcount = parseInt($rootScope.user_jobcount) + 1;
					$scope.savedjobs.push(job)
					updateColor()
					$scope.message = job.title+" has been added to Saved Jobs";
					$('#info').modal();
				else
					$scope.message = response.data.result;
					$('#info').modal();
		$scope.removeJob = (job) ->
			$http({url: '/api/removeJob', params: {job_id: job.id["$oid"]}}).then (response) ->
				if response.data.result == "success"
					$rootScope.user_jobcount = parseInt($rootScope.user_jobcount) - 1;
					rjob = null
					for i in $scope.savedjobs
						if i.id["$oid"] == job.id["$oid"]
							rjob = i
							break
					ind = $scope.savedjobs.indexOf(rjob)
					$scope.savedjobs.splice(ind, 1)
					updateColor()
					$scope.message = job.title+" has been removed from Saved Jobs";
					$('#info').modal();
					# alert("Removed from Saved Jobs")

		updateColor = () ->
			if $scope.savedjobs
				for i in $scope.jobs
					i.bgcolor = "#0F2938";
				for i in $scope.savedjobs
					for j in $scope.jobs
						if i.id["$oid"] == j.id["$oid"]
							j.bgcolor = "#427306";

		$scope.selectedJob = (job) ->
			$scope.selectedj = job

		$scope.gomatches = () ->
			$state.go("matches")
		$scope.gosavedjobs = () ->
			$state.go("savedjobs")

		$scope.findJobs = () ->
	  	$scope.loading = true;$http({url: "/api/jobs", method: "GET", params : {address: $scope.address, radius: $scope.radius}}).then (response) ->
															$scope.loading = false;
															$scope.jobs = response.data.jobs;
															$scope.lat = response.data.lat;
															$scope.lng = response.data.lng;
															if(response.data.all == true)
																$scope.alljobs = true;
																# $timeout(hidealljobsinfo, 5000)
															initializeMap();
		return
	]
	return