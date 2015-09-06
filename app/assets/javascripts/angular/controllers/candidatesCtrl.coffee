do ->
	app = angular.module 'instajob'
	app.controller 'candidatesCtrl', ["candidates", "$scope", "job", "$http", "matchedusers", (candidates, $scope, job, $http, matchedusers) ->
		$scope.candidates = candidates;
		$scope.job = job;
		$scope.matchedusers = matchedusers;
		$scope.selectedc = null;
		$scope.message = null;
		updateColors = () ->
			for i in $scope.candidates
				i.bgcol = "#0F2938"
			if $scope.matchedusers
				for i in $scope.matchedusers
					for j in $scope.candidates
						if i.id["$oid"] == j.id["$oid"]
							j.bgcol = "#427306"

		$scope.selectedCandidate = (candidate) ->
			$scope.selectedc = candidate;

		$scope.match = (candidate) ->
			$http({url: '/api/match', method: 'POST', data: {cid : candidate.id["$oid"], jid: $scope.job.id["$oid"]}}).then (response) ->
				if response.data.result == "success"
					$scope.message = candidate.name+" has been notified about the match. We have also shared your contact information with "+candidate.name;
					$("#info").modal();
					candidate.bgcol = "#427306"

		$scope.removeMatch = (candidate) ->
			$http({url: '/api/removematch', method: 'POST', data: {cid: candidate.id["$oid"], jid: $scope.job.id["$oid"]}}).then (response) ->
				$scope.message = candidate.name+" has been removed from "+$scope.job.title;
				$('#info').modal();
				candidate.bgcol = "#0F2938"

		updateColors();

	]
	return