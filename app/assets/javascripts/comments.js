var reddit_url  = "http://www.reddit.com/";
var subreddit   = "r/LaunchCodeCS50x/";
var comment_url = "comments/";
var post_url    = "";
var max_depth   = 9;
var padding     = 5;
var text_height = 100;
var auth_token  = "";

// Turbolinks workaround
$(document).ready(init_comments);
$(document).on('page:load', init_comments);

// Used for accessing classes and ids added to html via ajax
$(window).load(function(){

  $("#continue").click(function(){
    continue_thread();
  });

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
});

function init_comments()
{
  // authenticity token for rails csrf
  auth_token = $("meta[name=csrf-token]").attr("content");

  // only run when in reddit#show
  if ($(".reddit_comments").length != 0)
  {
    // reddit vars
    var ext = ".json";
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

          html += "</div>";
        }

        // output
        $(".reddit_comments").html(html);
        $(".reply_area").hide();
      }
    });
  }
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
