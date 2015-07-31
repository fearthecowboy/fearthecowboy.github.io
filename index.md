---
layout: page
title: Garrett Serack
tagline: A rather different, out-of-the-box Senior Open Source Software Engineer. 
---
{% include JB/setup %}
## #include
It would be a rare day that I’m not solving a problem, challenging the status quo, or turning some assumptions upside down to see what can actually be accomplished. I strive to have a positive impact while maintaining a pragmatic approach to solving problems. Even when things didn’t turn out exactly as I planned, I can honestly say that everything tended to turn out pretty great. 


## # Posts

<ul class="posts">
  {% for post in site.posts %}
    <li><span>{{ post.date | date_to_string }}</span> &raquo; <a href="{{ BASE_PATH }}{{ post.url }}">{{ post.title }}</a></li>
  {% endfor %}
</ul>




