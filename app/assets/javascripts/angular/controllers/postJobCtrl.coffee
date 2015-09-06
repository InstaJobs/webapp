do ->
	app = angular.module 'instajob'
	app.controller 'postJobCtrl', ['myjobs', 'mycompanies', '$scope', '$http', '$timeout', "uiGmapGoogleMapApi", (myjobs, mycompanies, $scope, $http, $timeout, uiGmapGoogleMapApi) ->
		$scope.ncf = false; #show new company form
		$scope.njf = false; #show new job form
		$scope.ncfbtnval = "Create"; #button value of new company form
		$scope.njfbtnval = "Create"; #button value of new company form
		$scope.enjfbtnval = "Update"; #button value of new company form
		$scope.modelshow = false;
		$scope.lat = null;
		$scope.lng = null;
		$scope.editjob = {};
		$scope.map = {};
		$scope.emap = {};
		$scope.newjob = {};
		$scope.editjob = null;
		$scope.marker = {
			options:{
				icon: "/map-marker-me.png",
				draggable: true
			},
			events: {

			},
			coord: {
				latitude: 4,
				longitude: 4
			}
		};
		$scope.emarker = {
			options:{
				icon: "/map-marker-me.png",
				draggable: true
			},
			events: {

			},
			coord: {
				latitude: 4,
				longitude: 4
			}
		};
		$scope.myjobs = myjobs;
		unless $scope.myjobs
			$scope.myjobs = []
		$scope.mycompanies = mycompanies;
		$scope.showjobs = [];
		for j in $scope.myjobs
			$scope.showjobs.push(j);
		$scope.selectedc = null;
		$scope.updateJobs = (company) ->
			$scope.selectedc = company;
			$scope.showjobs = [];
			for j in $scope.myjobs
				company_id = j.companyid || j.company_id["$oid"]
				if company_id == company.id["$oid"]
					$scope.showjobs.push(j)
			return
		$scope.createCompany = (newcompany) ->
			$http.post('/api/companies', newcompany).then (response) ->
				if response.data.result == "success"
					$scope.ncfbtnval = "Created";
					newcompany.id = response.data.id;
					$scope.mycompanies.push(newcompany);
				else
					$scope.ncfbtnval = "Error";
				$timeout ()->
					$scope.ncfbtnval = "Create"
					$scope.ncf = false;
				,2000

		$scope.createJob = (newjob) ->
			unless($scope.selectedc)
				alert("Select a company")
				return
			# console.log(newjob)
			newjob.companyid = $scope.selectedc.id["$oid"]
			newjob.lat = $scope.lat;
			newjob.lng = $scope.lng;
			newjob.address = $scope.newjob.address;
			$http.post('/api/jobs', newjob).then (response) ->
				if response.data.result == "success"
					$scope.njfbtnval = "Created"
					newjob.location = [newjob.lat, newjob.lng]
					newjob.id = response.data.id;
					newjob.company_id = $scope.selectedc.id;
					newjob.address = response.data.address
					newjob.users_liked = 0;
					$scope.myjobs.push(angular.copy(newjob));
					$scope.showjobs.push(angular.copy(newjob));
				else
					$scope.njfbtnval = "Error";
				$timeout () ->
					$scope.njfbtnval = "Create"
					$scope.njf = false;
				,2000

		showPosition = (position) ->
			$scope.lat = position.coords.latitude;
			$scope.lng = position.coords.longitude;
			$scope.map = {
				center: { latitude: $scope.lat, longitude: $scope.lng};
			};
			$scope.marker.coord =  {latitude: $scope.lat, longitude: $scope.lng}; 
			$scope.$apply();
			return true

		$scope.$watchCollection 'marker.coord', -> 
			$scope.lat = $scope.marker.coord.latitude
			$scope.lng = $scope.marker.coord.longitude
			$scope.map.center = {latitude: $scope.lat, longitude: $scope.lng};
			$http({url: '/getaddress', params: {lat: $scope.lat, lng: $scope.lng}}).then (response) ->
				$scope.newjob.address = response.data.result

		$scope.$watchCollection 'emarker.coord', -> 
			if $scope.editjob
				$scope.editjob.lat = $scope.emarker.coord.latitude
				$scope.editjob.lng = $scope.emarker.coord.longitude
				$scope.emap.center = {latitude: $scope.editjob.lat, longitude: $scope.editjob.lng};
				$http({url: '/getaddress', params: {lat: $scope.editjob.lat, lng: $scope.editjob.lng}}).then (response) ->
					$scope.editjob.address = response.data.result

		$scope.toggleLatLng = () ->
			if(navigator.geolocation)
				navigator.geolocation.getCurrentPosition(showPosition);
			else
				alert("Browser not supported");
			return true

		$scope.toggleLatLng();
		
		$scope.edit = (job) ->
			$timeout ()->
				$scope.modalshow = true
			,1000
			$scope.editjob = job;
			$scope.editjob.lat = $scope.editjob.location[0]
			$scope.editjob.lng = $scope.editjob.location[1]
			$scope.emarker.coord = {latitude: $scope.editjob.lat, longitude: $scope.editjob.lng};
			$scope.emap.center = {latitude: $scope.editjob.lat, longitude: $scope.editjob.lng};

		$scope.etoggleLatLng = () ->
			if(navigator.geolocation)
				navigator.geolocation.getCurrentPosition(showPosition);
			else
				alert("Browser not supported");
			return true
		$scope.updateJob = (editjob) ->
			editjob.lat = $scope.editjob.lat;
			editjob.lng = $scope.editjob.lng;
			$scope.enjfbtnval = "Updating ...";
			editjob.address = $scope.editjob.address
			editjob.companyid = editjob.company_id["$oid"]
			$http({url: '/api/jobs/'+editjob.id["$oid"], method: 'PATCH', data: editjob}).then (response) ->
				if response.data.result == "success"
					$scope.enjfbtnval = "Updated"
					editjob.location = [editjob.lat, editjob.lng]
					$timeout ()->
						$scope.enjfbtnval = "Update"
					,2000

		$scope.deleteJob = (job) ->
			job.companyid = job.company_id["$oid"]
			$http({url: '/api/jobs/'+job.id["$oid"], method: 'DELETE', params: {companyid: job.companyid}}).then (response) ->
				if response.data.result == "success"
					delete job.companyid
					ind = $scope.myjobs.indexOf(job);
					$scope.myjobs.splice(ind, 1)
					ind = $scope.showjobs.indexOf(job);
					$scope.showjobs.splice(ind, 1)

		$scope.getLatLngfAdd = (address) ->
			$http({url: '/getlatlng', method: 'GET', params: {address: address}}).then (response) ->
				$scope.lat = response.data.result[0];
				$scope.lng = response.data.result[1];
				$scope.map.center = {latitude: $scope.lat, longitude: $scope.lng};
				$scope.marker.coord = {latitude: $scope.lat, longitude: $scope.lng};
		$scope.egetLatLngfAdd = (address) ->
			$http({url: '/getlatlng', method: 'GET', params: {address: address}}).then (response) ->
				$scope.editjob.lat = response.data.result[0];
				$scope.editjob.lng = response.data.result[1];
				$scope.emap.center = {latitude: $scope.editjob.lat, longitude: $scope.editjob.lng};
				$scope.emarker.coord = {latitude: $scope.editjob.lat, longitude: $scope.editjob.lng};
		return
	]
	return