var logo_height = 100;
var menu_height = 0;
var menu_width  = 200;
var reddit_url  = "http://www.reddit.com/";
var subreddit   = "r/LaunchCodeCS50x/";
var comment_url = "comments/";
var post_url    = "";
var max_depth   = 9;
var padding     = 5;
var text_height = 100;
var auth_token  = "";
var ext = ".json";

// Turbolinks workaround
$(document).ready(ready);
$(document).on('page:load', ready);

// Used for accessing classes and ids added to html via ajax
$(window).load(function(){

  $(".comment_reply").click(function(){

    var width = $(this).width() - (padding * 2);
    if ($(this).text() == "reply")
    {
      $(this).html(generate_textarea($(this).attr('id')));
    }
  });

  $(".reply_text").click(function(){
    $('.reply_area').hide();
    $('.reply_text').show();
    $(this).hide();
    var id = $(this).parent('div')[0].id;
    $('#' + id).find('.reply_area:first').show();
  });

  $(".cancel").click(function(){
    var parent_id = $('#' + $(this).parents('div')[1].id);
    parent_id.find('.reply_area').hide();
    parent_id.find('.submit_reply').val("");
    parent_id.find('.reply_text').show();
  });

  $("#refresh_captcha").click(function(event){
    event.preventDefault();
    get_new_captcha();
  });

  $("#mark_read").click(function(event){
    event.preventDefault();
    var checks = [];
    $(".checkbox").each(function(){
      if ($(this).prop("checked"))
        checks.push($(this).attr('id'));
    });
    $.post('/mark_read', {names: checks}, function(){
      $("#inbox").load('/inbox #inbox');
    });
  });

  $("#search_button").click(function(event){
    event.preventDefault();
    var options = {};
    options['query'] = $("#query").val();
    options['restrict'] = $("#restrict_sr").prop("checked");
    search_reddit(options);
  });

  $("#pset_button").click(function(event){
    event.preventDefault();
    var options = {};
    var query = "";
    $(".pset_options").each(function(){
      if ($(this).prop("checked"))
        query += $(this).attr('id') + " ";
    });
    options['query'] = query;
    options['restrict'] = $("#restrict_sr").prop("checked");
    search_reddit(options);
  });
});

function ready()
{
  var controller = $('body').data('controller');

  // controller#action specific js
  // reddit
  if (controller == "reddit_post" ||
      controller == "pages")
  {
    var action = $('body').data('action');

    if (action == "index")
    {
      get_num_comments();
    }
    else if (action == "show")
    {
      init_comments();
    }
    else if (action == "new_link" ||
             action == "pm")
    {
      get_new_captcha()
    }
  }
  // Twitter
  else if (controller == "tweet")
  {
  }

  $("#continue").click(function(){
    continue_thread();
  });

  $("#nav-reddit").mouseenter(function(){
    $("#r_menu").show();
  });

  $("#nav-reddit").mouseleave(function(){
    $("#r_menu").hide();
    $("#r_menu").mouseenter(function(){
      $("#r_menu").show();
    });
    $("#r_menu").mouseleave(function(){
      $("#r_menu").hide();
    });
  });

  $(".tweet").mouseenter(function(){
    $(this).prev().css({
      "border-bottom":"1px solid #0084b4"
    });
    $(this).css({
      "border-bottom":"1px solid #0084b4"
    });
  });

  $(".tweet").mouseleave(function(){
    $(this).prev().css({
      "border-bottom":"1px solid #d0d0d0"
    });
    $(this).css({
      "border-bottom":"1px solid #d0d0d0"
    });
  });
}

function get_num_comments()
{
  // number of posts per page, from model
  var per_page = 10;

  // parameters to pass to scraper
  var url_options = "?limit=" + per_page + 
                    "&after=" + $("#after").attr('class'); 

  // combined url
  var fullurl  = reddit_url + subreddit + "new/" + ext + url_options;
  
  // grab data
  $.getJSON(fullurl, function(json){
    var results = json.data.children;

    // check results exist
    if (results)
    {
      // loop through results
      for (var i = 0, len = results.length; i < len; i++)
      {
        // set vars to clear things up
        var post_data = results[i].data;
        var current   = $(".num_comments").eq(i);

        // make sure scraped data corresponds to what is actually on page
        if (post_data.name == current.prev().attr('id'))
        {
          // pluralization check
          if (post_data.num_comments == 1)
          {
            current.html(post_data.num_comments + " Comment");
          }
          else
          {
            current.html(post_data.num_comments + " Comments");
          }
        }
      }
    }
  });
}

function init_comments()
{
  // authenticity token for rails csrf
  auth_token = $("meta[name=csrf-token]").attr("content");

  // html for output
  var html = "";

  // grab fullname var of post
  var fullname = $(".reddit_comments").attr('id').substring(3);

  // full url to query
  var fullurl = reddit_url + subreddit + comment_url + fullname + ext;

  $.getJSON(fullurl, function(json){

    // json[0] is original post, json[1] is comments section
    var comments = json[1].data.children;

    // possible truncated comments
    if (json[0].data.children[0].data.num_comments > max_depth);
    {
      post_url = json[0].data.children[0].data.url;
    }

    // only loop if there are comments
    if (comments.length > 0)
    {
      // loop through comments
      for (var i = 0, len = comments.length; i < len; i++)
      {
        var depth = 1;

        // wrap each comment thread
        html += "<div class=\"post_comment\">";
        html +=   "<div class=\"comment_body\">";

        var thread = comments[i].data;

        // link to author's reddit overview
        html += "<a href=\"" + reddit_url + "u/" + thread.author + "\">" +
                thread.author +
                "</a>" + " "; 
        html += timeSince(thread.created_utc) + "<br/>";
        html += $("<span/>").html(thread.body_html).text();
        html += "<br/></div>";

        html += "<div class=\"comment_reply\" id=\"" + thread.name + "\">";
        html += "<div class=\"reply_text\">reply</div>";
        html += generate_textarea(thread.name);
        

        html += replies(thread.replies, depth);

        html += "</div></div>";
      }

      // output
      $(".reddit_comments").html(html);
      $(".reply_area").hide();
    }
  });
}

function get_new_captcha()
{
  $.get('/captcha', function(response){ 
    var data = $(response)[$(response).length - 2];
    var captcha_id = $(data).text();
    var image_link = reddit_url + "captcha/" + captcha_id + ".png";
    $("#captcha_id").attr("value", captcha_id);
    $("#captcha_img").attr({
      src: image_link,
      alt: captcha_id
    });
  }, "html");
}

/*
 * Returns the html output for the replies to the comments
 */
function replies(reps, curr_depth)
{
  var html_out = "";

  // check for presence of replies
  if (jQuery.isEmptyObject(reps) == false)
  {
    var thread = reps.data.children;
    // loop through each reply thread of comment
    for (var i = 0, len = thread.length; i < len; i++)
    {
      var obj = thread[i].data;

      // add div class
      html_out += "<div class=\"post_comment\">";
      html_out +=   "<div class=\"comment_body\">";

      html_out += "<a href=\"" + reddit_url + "u/" + obj.author + "\">" +
              obj.author +
              "</a>" + " "; 
      html_out += timeSince(obj.created_utc) + "<br/>";
      html_out += jQuery.isEmptyObject(obj.body_html) ? "" :
                    $("<span/>").html(obj.body_html).text();
      html_out += "<br/></div>";

      if (curr_depth < max_depth)
      {
        curr_depth++;
        html_out += "<div class=\"comment_reply\" id=\"" + obj.name + "\">";
        html_out += "<div class=\"reply_text\">reply</div>";
        html_out += generate_textarea(obj.name);
        html_out += "</div>";
        html_out += replies(obj.replies, curr_depth);
      }
      else
      {
        html_out += "<div class=\"comment_reply\" id=\"continue\">";
        html_out += "Continue This Thread";
        html_out += "</div>";
      }

      html_out += "</div>";
    }
  }

  return html_out;
}

function continue_thread() 
{
  $("#continue").html();
}

function generate_textarea(id)
{
  var textarea = "<div class=\"reply_area\">" + 
                 "<form name=\"" + id + "\"" +
                       "action=\"/send_comment\"" +
                       "method=\"post\">" +
                 "<input name=\"fullname\"" + 
                        "type=\"hidden\"" + 
                        "value=\"" + id + "\">" +
                 "<input name=\"authenticity_token\"" + 
                        "type=\"hidden\"" +
                        "value=\"" + auth_token + "\">" +
                 "<textarea class=\"submit_reply\" name=\"message\"></textarea><br/>" +
                 "<input type=\"submit\" value=\"save\">" + 
                 "<button type=\"button\" class=\"cancel\">" + 
                   "Cancel" + 
                 "</button></form></div><br/>";
  return textarea;
}

function search_reddit(options)
{
  var fullurl = reddit_url + subreddit + "search" + ext + "?";
  if (options['restrict'])
    fullurl += "restrict_sr=true&";

  var query = "q=";
  $.each(options['query'].split(' '), function(i, value){
    if (i == 0)
      query += value;
    else
      query += "+" + value;
  });

  // 2 additional characters are needed to account for q=
  if (query.length > 2 && query.length <= 514)
  {
    fullurl += query;
    $.getJSON(fullurl, function(json){
      var results = json.data.children;
      var html = "";

      if (results)
      {
        $.each(results, function(i, value){
          html += format_result(value.data);
        });
      }
      
      $("#results").html(html).text();
    });
  }
  else
    alert("Search terms must be between 1 and 512 characters.");
}

function format_result(result)
{
  var output = "";
  
  if (result.is_self && result.domain == "self.LaunchCodeCS50x")
    output += title_link(result.title, "reddit/" + result.name);
  else
    output += title_link(result.title, result.url);

  output += "<span class=\"post_domain\">(" + result.domain + ")</span><br/>";
  output += "<div class=\"post_byline\">";
  output += "submitted " + timeSince(result.created_utc) + " by "; 
  output += "<a href=\"" + reddit_url + "u/" + result.author + "\">"; 
  output += result.author;
  output += "</a></div><br/>";

  if (result.is_self)
  {
    output += "<div class=\"post_content\">"; 
    output += $("<span/>").html(result.selftext_html).text() + "</div><br/>";
  }
  return output;
}

function title_link(title, url){
  var out = "<a href=\"" + url + "\"><span class=\"post_title\">";
  out += title + "</span></a> ";
  return out
}

/*
 * Return time since link was posted
 * http://stackoverflow.com/a/3177838/477958
 */
function timeSince(date) {
  var seconds = Math.floor(((new Date().getTime()/1000) - date))
 
  var interval = Math.floor(seconds / 31536000);
 
  if (interval >= 1) {
    if(interval == 1) return interval + " year ago";
    else
      return interval + " years ago";
  }
  interval = Math.floor(seconds / 2592000);
  if (interval >= 1) {
    if(interval == 1) return interval + " month ago";
    else
      return interval + " months ago";
  }
  interval = Math.floor(seconds / 86400);
  if (interval >= 1) {
    if(interval == 1) return interval + " day ago";
    else
      return interval + " days ago";
  }
  interval = Math.floor(seconds / 3600);
  if (interval >= 1) {
    if(interval == 1) return interval + " hour ago";
    else
      return interval + " hours ago";
  }
  interval = Math.floor(seconds / 60);
  if (interval >= 1) {
    if(interval == 1) return interval + " minute ago";
    else
      return interval + " minutes ago";
  }
  return Math.floor(seconds) + " seconds ago";
}
