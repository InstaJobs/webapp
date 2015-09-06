class HomeController < ApplicationController
	require 'securerandom'

	layout 'application'

  def landing
  	render template: "home/landing", layout: false
  end

  def connect
    unless session[:user_id].nil?
      redirect_to '/dashboard'
    end
  end

  def featuredjobs
    @jobs = Job.order("created_at DESC").limit(10)
    render :json => @jobs
  end

  def logout
    session[:user_id] = nil
    Analytics.track(
      user_id: session[:user_id].to_s,
      event: 'Logged Out'
    )
    render :json => {result: "success"}
  end

  def getlatlng
    address = params[:address]
    lat, lng = Geocoder.coordinates(address)
    render :json => {:result => [lat, lng]}
  end

  def getaddress
    lat, lng = params[:lat], params[:lng]
    address = Geocoder.address(lat.to_s+" "+lng.to_s)
    render :json => {:result => address}
  end

  def fb
  	fbparam = fbparams(params)
  	newsignup = false
  	@u = User.where(:email => fbparam[:email]).first
  	if @u
  		@u.facebook_profile = FacebookProfile.new(:uid => fbparam[:id], :access_token => fbparam[:access_token])
  	else
  		@u = User.new
  		@u.name = fbparam[:name]
  		@u.email = fbparam[:email]
  		@u.email_verified = true
  		@u.password = SecureRandom.hex(6)
  		@u.facebook_profile = FacebookProfile.new(:uid => fbparam[:id], :access_token => fbparam[:access_token])
      mobiletoken = SecureRandom.urlsafe_base64
      while(User.where(:mobiletoken => mobiletoken).size != 0)
        mobiletoken = SecureRandom.urlsafe_base64
      end
      @u.mobiletoken = mobiletoken
  		newsignup = true
      @u.jobmatches = []
  	end
  	if @u.save
  		if newsignup
  			# TODO move mailer to background queue
        FbWorker.perform_async(@u.id.to_s, @u.password)
  		end
	  	session[:user_id] = @u.id
      render :json => {result: "success", token: @u.mobiletoken, username: @u.name}
  	else
  		render :json => {result: "save error" + @u.errors.full_messages.join(" ")}
  	end
    Analytics.track(
      user_id: session[:user_id].to_s,
      event: 'Facebook Login',
      properties: {email: "#{@u.email}", name: "#{@u.name}"}
    )
  end

  def linkedin
    inparam = inparams(params)
    newsignup = false
    @u = User.where(:email => inparam[:emailAddress]).first
    if @u
      @u.linked_in_profile = LinkedInProfile.new(:uid => inparam[:id], :first_name => inparam[:firstName], :last_name => inparam[:lastName])
    else
      @u = User.new
      @u.name = inparam[:firstName] + inparam[:lastName]
      @u.email = inparam[:emailAddress]
      @u.email_verified = true
      @u.password = SecureRandom.hex(6)
      @u.linked_in_profile = LinkedInProfile.new(:uid => inparam[:id], :first_name => inparam[:firstName], :last_name => inparam[:lastName])
      mobiletoken = SecureRandom.urlsafe_base64
      while(User.where(:mobiletoken => mobiletoken).size != 0)
        mobiletoken = SecureRandom.urlsafe_base64
      end
      @u.mobiletoken = mobiletoken
      newsignup = true
      @u.jobmatches = []
    end
    if @u.save
      if newsignup
        FbWorker.perform_async(@u.id.to_s, @u.password)
      end
      session[:user_id] = @u.id
      render :json => {result: "success", token: @u.mobiletoken, username: @u.name}
    else
      render :json => {result: "save error" + @u.errors.join(" ")}
    end  
    Analytics.track(
      user_id: session[:user_id].to_s,
      event: 'LinkedIn Login',
      properties: {email: "#{@u.email}", name: "#{@u.name}"}
    )
  end

  def genpassword
    @email = params[:email]
    @user = User.where(:email => @email).first
    unless @user
      render :json => {result: "user not found"}
    end
    @user.password = SecureRandom.hex(6)
    if @user.save
      Analytics.track(
        user_id: @u.id.to_s,
        event: 'Forgot Password',
        properties: {email: "#{@u.email}", name: "#{@u.name}", ip: request.remote_ip, agent: request.user_agent}
      )
      FbWorker.perform_async(@user.id.to_s, @user.password)
      render :json => {result: "success"}
    else
      render :json => {result: "save error"}
    end
  end

  def signup
  	sparams = signup_params(params)
  	@u = User.new()
  	@u.name = sparams[:name]
  	@u.email = sparams[:email]
  	@u.password = sparams[:password]
    mobiletoken = SecureRandom.urlsafe_base64
    while(User.where(:mobiletoken => mobiletoken).size != 0)
      mobiletoken = SecureRandom.urlsafe_base64
    end
    @u.mobiletoken = mobiletoken 
  	if(User.where(:email => @u.email).size != 0)
  		render :json => {result: "The given email is already registered"}
  		return
  	end
  	verify_token = SecureRandom.urlsafe_base64
  	while(User.where(:email_verify_token => verify_token).size != 0)
  		verify_token = SecureRandom.urlsafe_base64
  	end
  	@u.email_verify_token = verify_token
    @u.jobmatches = []
  	if @u.save
      Analytics.track(
        user_id: @u.id.to_s,
        event: 'Signed Up',
        properties: {email: "#{@u.email}", name: "#{@u.name}", ip: request.remote_ip, agent: request.user_agent}
      )
	  	# TODO move mailer to background queue
      SignupWorker.perform_async(@u.id.to_s)
      render :json => {result: "success", token: @u.mobiletoken, username: @u.name}
  	else
	  	render :json => @u.errors.full_messages.join(" ")
  	end
  end

  def login
  	lparams = login_params(params)
  	@u = User.where(:email => lparams[:email]).first
  	if !@u
  		render :json => {result: "No user registered with this email"}
  	else
  		pass = lparams[:password]
  		unless @u.email_verified
  			render :json => {result: "Email not verified"}
  			return
  		end
  		if @u.authenticate(pass)
        Analytics.identify(
          user_id: @u.id.to_s,
          traits: {email: "#{@u.email}", name: "#{@u.name}"},
          context: {ip: request.remote_ip, agent: request.user_agent},
        )
  			session[:user_id] = @u.id
  			render :json => {result: "success", token: @u.mobiletoken, username: @u.name}
  		else
  			render :json => {result: "password did not match"}
  		end
  	end
  end

  def verify
  	token = params[:token]
  	@u = User.where(:email_verify_token => token).first
  	if !@u
  		render :json => {result: "invalid token"} 
  	else 
      Analytics.track(
        user_id: @u.id.to_s,
        event: 'Verify Email',
        properties: {email: "#{@u.email}", name: "#{@u.name}", ip: request.remote_ip, agent: request.user_agent}
      )
  		@u.email_verified = true
  		@u.save
      redirect_to "/"
  	end
  end

  private 
  def signup_params(params)
  	params.permit(:name, :email, :password)
  end

  def login_params(params)
  	params.permit(:email, :password)
  end

  def fbparams(params)
  	params.permit(:email, :name, :id, :access_token)
  end

  def inparams(params)
    params.permit(:emailAddress, :firstName, :lastName, :id)
  end
end