class PackagesController < ApplicationController
  before_action :set_package, only: [:show, :edit, :update, :destroy]

  before_action :set_search_params, :only => :index
  before_action :set_facet_params, :only => :index

  include TeSS::BreadCrumbs

  @@facet_fields = %w( user keywords )

  # GET /packages
  # GET /packages.json
  def index
    @facet_fields = @@facet_fields
    if SOLR_ENABLED
      @packages = solr_search(Package, @search_params, @@facet_fields, @facet_params)
    else
      @packages = Package.all
    end

  end

  # GET /packages/1
  # GET /packages/1.json
  def show
  end

  # GET /packages/new
  def new
    authorize Package
    @package = Package.new
  end

  # GET /packages/1/edit
  def edit
    authorize @package
  end

  # POST /packages
  # POST /packages.json
  def create
    authorize Package
    @package = Package.new(package_params)
    @package.user = current_user

    respond_to do |format|
      if @package.save
        @package.create_activity :create, owner: current_user
        current_user.packages << @package
        format.html { redirect_to @package, notice: 'Package was successfully created.' }
        format.json { render :show, status: :created, location: @package }
      else
        format.html { render :new }
        format.json { render json: @package.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /packages/1
  # PATCH/PUT /packages/1.json
  def update
    authorize @package
    respond_to do |format|
      if @package.update(package_params)
        @package.create_activity :update, owner: current_user
        format.html { redirect_to @package, notice: 'Package was successfully updated.' }
        format.json { render :show, status: :ok, location: @package }
      else
        format.html { render :edit }
        format.json { render json: @package.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /packages/1
  # DELETE /packages/1.json
  def destroy
    authorize @package
    @package.create_activity :destroy, owner: current_user
    @package.destroy
    respond_to do |format|
      format.html { redirect_to packages_url, notice: 'Package was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def manage
    @package = Package.friendly.find(params[:package_id])
    @materials = @package.materials
    @events = @package.events
  end

=begin
  def remove_resources
    @package = Package.friendly.find(params[:package_id])
    remove_resources_from_package(params[:package][:material_ids], params[:package][:event_ids])
    if true
      respond_to do |format|
        format.html { redirect_to @package, notice: 'Package was successfully updated.' }
        format.json { render :show, status: :ok, location: @package }
      end
    end
  end
=end

  def update_package_resources
    @package = Package.friendly.find(params[:package_id])
    @package = add_resources_to_package(@package, params[:package][:material_ids], params[:package][:event_ids])
    if @package.save!
      respond_to do |format|
        format.html { redirect_to @package, notice: 'Package contents updated.' }
        format.json { render :show, status: :ok, location: @package }
      end
    end
  end

  private
=begin
    def remove_resources_from_package(materials, events)
      remove_materials_from_package(materials) if !materials.nil? and !materials.empty?
      remove_events_from_package(events) if !events.nil? and !events.empty?
    end

    def remove_materials_from_package(materials)
      materials.collect{|ev| Material.find_by_id(ev)}.each do |x|
        @package.materials.delete(x) unless x.nil?
      end
    end

    def remove_events_from_package(events)
      events.collect{|ev| Event.find_by_id(ev)}.each do |x|
        @package.events.delete(x) unless x.nil?
      end
    end
=end

  # Use callbacks to share common setup or constraints between actions.
    def set_package
      @package = Package.friendly.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def package_params
      params.require(:package).permit(:title, :description, :image_url, :public, {:keywords => []})
    end

    def set_search_params
      params.permit(:q)
      @search_params = params[:q] || ''
    end

    def set_facet_params
      params.permit(@@facet_fields, @@facet_fields.map{|f| "#{f}_all"})
      @facet_params = {}
      @@facet_fields.each {|facet_title| @facet_params[facet_title] = params[facet_title] if !params[facet_title].nil? }
    end


end
