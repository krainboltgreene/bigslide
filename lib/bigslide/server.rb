require "sinatra/base"
require_relative "../bigslide"

module Bigslide
  class Server < Sinatra::Base
    set :logging, true
    set :root, File.dirname(File.join(__FILE__, "..", ".."))

    INDEX_URI = "http://feeds.boston.com/boston/bigpicture/index"
    INDEX = Nokogiri::XML(open(INDEX_URI)).css("item link").map(&:inner_text)
    IMAGES = INDEX.map do |group_uri|
      Nokogiri::HTML(open(group_uri)).css(".bpImage").map { |n| n["src"] }.map.with_index do |image_uri, index|
        {
          position: index,
          source: image_uri,
          class: ("active" if index.zero?)
        }
      end
    end
    TEMPLATE = <<-TEMPLATE
<!DOCTYPE html>
<!--[if lt IE 7]> <html class="no-js lt-ie9 lt-ie8 lt-ie7"> <![endif]-->
<!--[if IE 7]> <html class="no-js lt-ie9 lt-ie8"> <![endif]-->
<!--[if IE 8]> <html class="no-js lt-ie9"> <![endif]-->
<!--[if gt IE 8]><!--> <html class="no-js"> <!--<![endif]-->
  <head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <title>Onebox Example</title>
    <meta name="description" content="An example of the onebox gem">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link href="//netdna.bootstrapcdn.com/bootstrap/3.0.2/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="/styles/bigslide.css">
  </head>
  <body>
    <!--[if lt IE 7]>
      <p class="browsehappy">You are using an <strong>outdated</strong> browser. Please <a href="http://browsehappy.com/">upgrade your browser</a> to improve your experience.</p>
    <![endif]-->

    <div id="bigslide" class="carousel slide" data-ride="carousel">
      <ol class="carousel-indicators">
        {{#images}}
          <li data-target="#bigslide" data-slide-to="{{position}}" class="{{class}}"></li>
        {{/images}}
      </ol>

      <!-- Wrapper for slides -->
      <div class="carousel-inner">
        {{#images}}
          <div class="item {{class}}">
            <img src="{{source}}" width="100%">
          </div>
        {{/images}}
      </div>

      <!-- Controls -->
      <a class="left carousel-control" href="#bigslide" data-slide="prev">
        <span class="glyphicon glyphicon-chevron-left"></span>
      </a>
      <a class="right carousel-control" href="#bigslide" data-slide="next">
        <span class="glyphicon glyphicon-chevron-right"></span>
      </a>
    </div>

    <script src="//ajax.googleapis.com/ajax/libs/jquery/1.10.2/jquery.min.js"></script>
    <script src="//netdna.bootstrapcdn.com/bootstrap/3.0.2/js/bootstrap.min.js"></script>
  </body>
</html>
      TEMPLATE

    get "/" do
      redirect "/slides/1"
    end

    get "/slides/:id" do |id|
      Mustache.render(TEMPLATE, images: IMAGES[id.to_i])
    end
  end
end
