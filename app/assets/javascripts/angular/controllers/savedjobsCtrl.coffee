do ->
	app = angular.module 'instajob'
	app.controller 'savedjobsCtrl', ["savedjobs", "$scope", (savedjobs, $scope) -> 
		$scope.jobs = savedjobs;
		$scope.selectedj = null;
		for j in $scope.jobs
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
						console.log(j.description.charAt(indlast))
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
		$scope.selectedJob = (job) ->
			$scope.selectedj = job;
	]
	return