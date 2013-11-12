require "sinatra/base"
require_relative "../bigslide"

module Bigslide
  class Server < Sinatra::Base
    set :logging, true

    INDEX_URI = "http://feeds.boston.com/boston/bigpicture/index"
    INDEX = Nokogiri::XML(open(INDEX_URI)).css("item link").map(&:inner_text)
    SLIDES = Slide[INDEX]

    TEMPLATE = <<-TEMPLATE
<!DOCTYPE html>
<!--[if lt IE 7]> <html class="no-js lt-ie9 lt-ie8 lt-ie7"> <![endif]-->
<!--[if IE 7]> <html class="no-js lt-ie9 lt-ie8"> <![endif]-->
<!--[if IE 8]> <html class="no-js lt-ie9"> <![endif]-->
<!--[if gt IE 8]><!--> <html class="no-js"> <!--<![endif]-->
  <head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <title>The Big Slide</title>
    <meta name="description" content="A slide of all the Big Shot">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link href="//netdna.bootstrapcdn.com/bootstrap/3.0.2/css/bootstrap.min.css" rel="stylesheet">
    <style type="text/css">
      .navbar-default.navbar-fixed-top {
        background: transparent;
        border-color: transparent;
        text-align: center;
      }

      .navbar-fixed-top button {
        background-color: rgba(52, 73, 94, 0.25);
        border-color: transparent;
      }

      .carousel-caption {
        margin-bottom: 125px;
        background-color: rgba(52, 73, 94, 0.25);
      }
    </style>
  </head>
  <body>
    <!--[if lt IE 7]>
      <p class="browsehappy">You are using an <strong>outdated</strong> browser. Please <a href="http://browsehappy.com/">upgrade your browser</a> to improve your experience.</p>
    <![endif]-->
    <nav class="navbar navbar-default navbar-fixed-top" role="navigation">
      <button type="button" class="btn btn-default navbar-btn">{{name}}</button>
    </nav>

    <div id="bigslide" class="carousel slide" data-ride="carousel" data-interval="3000" data-wrap="false" data-interval="false">
      <ol class="carousel-indicators">
        {{#images}}
          <li data-target="#bigslide" data-slide-to="{{position}}" class="{{active}}"></li>
        {{/images}}
      </ol>

      <div class="carousel-inner">
        {{#images}}
          <div class="item {{active}}">
            <img src="{{source}}" width="100%">
            <div class="carousel-caption">
              <p>
                {{caption}}
              </p>
            </div>
          </div>

        {{/images}}
      </div>

      <a class="left carousel-control" href="#bigslide" data-slide="prev">
        <span class="glyphicon glyphicon-chevron-left"></span>
      </a>
      <a class="right carousel-control" href="#bigslide" data-slide="next">
        <span class="glyphicon glyphicon-chevron-right"></span>
      </a>
    </div>

    <nav class="navbar navbar-default" role="navigation">
      {{#meta}}
        <a href="/slides/{{back}}">
          <button type="button" class="btn btn-default navbar-btn">Back</button>
        </a>
        <a href="/slides/{{forward}}">
          <button type="button" class="btn btn-default navbar-btn navbar-right">Forward</button>
        </a>
      {{/meta}}
    </nav>

    <script src="//ajax.googleapis.com/ajax/libs/jquery/1.10.2/jquery.min.js"></script>
    <script src="//netdna.bootstrapcdn.com/bootstrap/3.0.2/js/bootstrap.min.js"></script>
    <script type="text/javascript">
      $("#bigslide").on("slid.bs.carousel", function() {
        if($(".carousel-inner .item:last").hasClass("active")) {
          setTimeout(function() {
            var href = $(".navbar a:last").attr("href");
            window.location = href;
          }, 3000);
        };
      });
      var last = $("#bigslide .image:last-of-type")
      last.trigger("cssClassChanged")
    </script>
  </body>
</html>
    TEMPLATE

    get "/" do
      redirect "/slides/0"
    end

    get "/slides/:id" do |id|
      Mustache.render(TEMPLATE, SLIDES[id.to_i].to_hash)
    end
  end
end
