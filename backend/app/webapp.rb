module Inventory
  require 'sinatra'

  class WebApp < Sinatra::Base

    require 'pp'
    require 'json'
    require_relative 'controller/config_controller'
    require_relative 'controller/item_controller'
    require_relative 'util/logging'

    configure do
      set :host_authorization, { permitted_hosts: [] }
      set :item_controller, Inventory::Controller::ItemController.new
      set :config_controller, Inventory::Controller::ConfigController.new
    end

    before do
      api_key = request.env['HTTP_X_AUTH_TOKEN']
      halt 401, 'Missing or invalid API key' unless api_key == ENV['INVENTORY_API_KEY']
    end

    get '/backend/items' do
      content_type :json
      stored = settings.item_controller.get_items
      stored.to_json
    end

    get '/backend/config' do
      content_type :json
      config = settings.config_controller.get_config
      if config.empty?
        status 500
      else
        config.to_json
      end
    end

    post '/backend/products' do
      content_type :json
      barcode = params[:barcode]
      product_name = params[:product_name]
      result = settings.item_controller.modify_barcode_mapping(barcode, product_name)
      if result != nil
        status 201
      else
        status 400
      end
    end

    post '/backend/items' do
      content_type :json
      storage_id = params[:storage_id]
      barcode = params[:barcode]
      result = settings.item_controller.add_item_with_barcode(storage_id, barcode)
      if result != nil
        status 201
        result.to_json
      else
        status 400
      end
    end

    delete '/backend/items' do
      content_type :json
      storage_id = params[:storage_id]
      barcode = params[:barcode]
      result = settings.item_controller.remove_item_with_barcode(storage_id, barcode)
      if result
        status 200
        result.to_json
      else
        status 400
      end
    end
  end
end
