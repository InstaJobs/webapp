$(document).ready () ->
	HandlebarsIntl.registerWith(Handlebars);
	validEmail = (email) -> 
  	regex = /^([a-zA-Z0-9_.+-])+\@(([a-zA-Z0-9-])+\.)+([a-zA-Z0-9]{2,4})+$/;
  	return regex.test(email);

	$.ajax
		url: '/featuredjobs'
		type: 'GET'
		success: (response) ->
			source   = $("#jobtemplate").html();
			template = Handlebars.compile(source);
			for j in response
				if j.title
					if(j.title.length > 30)
						j.short_title = j.title.substring(0, 30)+".."
					else
						j.short_title = j.title
				if j.description
					j.short_description = j.description.substring(0, Math.min(j.description.length, 140))
				if j.responsibility
					j.short_responsibility = j.responsibility.substring(0, Math.min(j.responsibility.length, 100))
				jobhtml = template(j);
				$(".jobs").append(jobhtml);
			ind = 1
			for j in response
				$(".jobs .div:nth-child("+ind+")").click({job: j}, showmodal)
				ind++;
		error: (error) ->
			console.log(error)

	showmodal = (event) ->
		modalsource = $("#jobmodals").html();
		modal = Handlebars.compile(modalsource);
		jobmodal = modal(event.data.job)
		$(jobmodal).modal();

	setsignbtn = () ->
		$("#signupbtn").html("Create account");

	setloginbtn = () ->
		$("#loginbtn").html("Sign In");

	setforgotbtn = () ->
		$("#forgotbtn").html("Forgot Password")		

	$('#signuphref').click () ->
		$('.loginform').fadeOut () ->
			$('.signupform').fadeIn()
			return
		$('.logbtn a:first-child').removeClass('selected');
		$('.signbtn a:first-child').addClass('selected');
		return 

	$('#loginhref').click () ->
		$('.signupform').fadeOut () -> 
			$('.loginform').fadeIn()
			return
		$('.signbtn a:first-child').removeClass('selected');
		$('.logbtn a:first-child').addClass('selected');
		return 

	$('#signupbtn').click (event) ->
		event.preventDefault();
		$("#signupbtn").html("Creating account.....")
		values = $('.signupf input');
		name = values[0].value
		email = values[1].value
		if(!validEmail(email))
			$("#message").html("Enter a valid email")
			$('#myModal').modal();
			$("#signupbtn").html("Create account")
			return
		password = values[2].value
		cpassword = values[3].value
		unless(password == cpassword)
			$("#signupbtn").html("Create account")
			$("#message").html("Passwords do not match")
			$('#myModal').modal();
			return
		unless(name and email and password)
			$("#signupbtn").html("Empty fields!!")
			setTimeout(setsignbtn, 1000);
			return
		$.ajax 
			url: '/signup'
			type: 'POST'
			data: {name : name, email : email, password : password}
			success: (response) ->
				if response.result == "success"
					$("#message").html("Check Mail")
					$('#myModal').modal();
				else 
					$("#message").html(response.result)
					$('#myModal').modal();
				setTimeout(setsignbtn, 2000);	values = $(".loginform form:first-child input");
			error: (error)->
				$("#message").html(error)
				$('#myModal').modal();
				setTimeout(setsignbtn, 2000);
		return

	$("#loginbtn").click (event) ->
		event.preventDefault();
		$("#loginbtn").html("Logging you in ...")
		values = $(".loginf input");
		email = values[0].value
		password = values[1].value
		unless(email and password)
			$("#loginbtn").html("Empty fields!!")
			setTimeout(loginbtn, 1000)
			return
		$.ajax
			url: '/login'
			type: 'POST'
			data: {email : email, password : password}
			success: (response) ->
				if response.result == "success"
					location.reload();
				else
					$("#message").html(response.result)
					$('#myModal').modal();
				return
			error: (error) ->
				$("#message").html(error)
				$('#myModal').modal();
			setTimeout(setloginbtn, 2000)
		return

	getUserInfo = (token) ->
		FB.api '/me', {fields: ['email', 'name']}, (response) ->
			#login
			name = response.name
			email = response.email
			id = response.id
			unless(email)
				$("#message").html("Email not fetched from facebook")
				$('#myModal').modal();
				return
			$(".fblogin").html("Connecting ..");
			$.ajax
				url: '/fb'
				type: 'POST'
				data: {email : email, name : name, id : id, access_token : token}
				success: (response) -> 
					if response.result == "success"
						location.reload();
						return false;
					else
						$("#message").html(response.result)
						$('#myModal').modal();
					return
				error: (error) ->
					$("#message").html(error)
					$('#myModal').modal();
			return

	$(".fblogin").click (event) ->
		event.preventDefault();
		FB.login (response) ->
			if(response.authResponse)
				getUserInfo(response.authResponse.accessToken)
			else
				$("#message").html('Authorization failed')
				$('#myModal').modal();
		, {scope: 'email'}	
		return

	linkedinlogin = ()->
		IN.API.Profile("me").fields("id", "firstName", "lastName", "email-address").result(linkedinloginsuccess).error(linkedinloginerror);

	linkedinloginsuccess = (profiles) ->
		$(".inlogin").html("Connecting ..")
		member = profiles.values[0];
		console.log(profiles.values[0]);
		$.ajax
			url: '/linkedin'
			type: 'POST'
			data: member
			success: (response) ->
				if response.result == "success"
					location.reload();
					return false;
				else
					$("#message").html(response.result)
					$('#myModal').modal();
				return
			error: (error) ->
				$("#message").html(error)
				$('#myModal').modal();
		return
		


	linkedinloginerror = () ->
		$("#message").html("Error")
		$('#myModal').modal();

	$(".inlogin").click (event) ->
		event.preventDefault();
		IN.User.authorize(linkedinlogin, window);

	$("#forgotbtn").click (event) ->
		event.preventDefault();
		values = $(".loginf input");
		email = values[0].value
		unless email
			$("#message").html("Enter email")
			$('#myModal').modal();
			return
		$.ajax
			url: '/forgotpassword'
			type: 'POST'
			data: {email: email}
			success: (response) ->
				if response.result == "success"
					$("#forgotbtn").html("Email Sent")
				else
					$("#forgotbtn").html("Error")
				return 
			error: (error) -> 
				$("#forgotbtn").html("Error")
				return 
			setTimeout(setforgotbtn, 2000)
		return
	return
