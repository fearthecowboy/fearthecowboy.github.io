---
layout: post
title: "PowerShell Hacks: Ternarys and Null-coalescing operators"
description: "A better solution for Ternary and Null-coalescing operators"
category: PowerShell
tags: [PowerShell, Ternary, Operator, Null-Coalescing, Hack]
---
{% include JB/setup %}

It took me a long time to actually start using PowerShell for my daily scripting tasks, mainly beacuse I was so damn good at CMD shell scripts, and it was such a hassle to learn to do everything differently.

However, as I worked more with PowerShell, I got to like it a lot, and now use it for virtually all my automation needs.

#### Daily dose of what's wrong

A couple of big gripes come from the lack of a decent ternary operator in the language--which is a very terse way of cramming a whole if/else statement into a single expression:

A C# Example:
{% highlight csharp %}
  // The ugly, bloated mess
  string dude;
  if( age > 50 ) {
    dude = "Old Man"
  } else {
    dude = "Young Punk"
  }

  // Using a ternary, cleans up your code!
  var dude = age > 50 ? "Old Man"  : "Young Punk";
{% endhighlight %}

## That time when someone tried to fix it with some duck-tape 

Sadly, there exists no comparable feature in PowerShell. Searching the internets, I found an attempt to make something that is kinda the same:

From a blog post by [Jeffrey Snover](http://blogs.msdn.com/b/powershell/archive/2006/12/29/dyi-ternary-operator.aspx): 

{% highlight powershell %}l
# ---------------------------------------------------------------------------
# Name:   Invoke-Ternary
# Alias:  ?:
# Author: Karl Prosser
# Desc:   Similar to the C# ? : operator e.g. 
#            _name = (value != null) ? String.Empty : value;
# Usage:  1..10 | ?: {$_ -gt 5} {"Greater than 5;$_} {"Not greater than 5";$_}
# ---------------------------------------------------------------------------
set-alias ?: Invoke-Ternary -Option AllScope -Description "PSCX filter alias"
filter Invoke-Ternary ([scriptblock]$decider, [scriptblock]$ifTrue, [scriptblock]$ifFalse) 
{
   if (&$decider) { 
      &$ifTrue
   } else { 
      &$ifFalse 
   }
}
{% endhighlight %}

Which lets one use a construct that looks like this:

{% highlight powershell %}
dude =  (?:  {$age -gt 50} {"Old Man"} {"Young Punk"})
{% endhighlight %}

*sigh* ... I'll give high marks for terse, but ... not really the same readability as a C-style ternary.

#### Hack like nobody is watching

I have made (in my ever-so-humble opinion) a far smarter way to accomplish the support of a Ternary in PowerShell.

Let's take a look at some examples, and I'll show the code to accomplish this at the end.

----
###### Simple, straightforward ternary
{% highlight powershell %}
$x == ( 'a' -eq 'a' ) ? "yes" : "no"
echo "Result: $x"
{% endhighlight %}

>  
{% highlight powershell %}
Result: yes
{% endhighlight %}

----
###### How about if it's false
{% highlight powershell %}
$x == ('a' -eq 'b' ) ? "that would be not correct" : "of course they are not equal"
echo "Result: $x"
{% endhighlight %}

>  
{% highlight powershell %}
Result: of course they are not equal
{% endhighlight %}

----
###### More fun
{% highlight powershell %}
$x == ('a' -lt 'b' ) ? ('a' -ne 'b') : ('a' -eq 'b' )
echo  "Result: $x"
{% endhighlight %}

>  
{% highlight powershell %}
Result: True
{% endhighlight %}

----
The other thing that's missing from a PowerShell is a null-coalescing operator. In a c# example:

{% highlight csharp %}
  // An ugly, bloated mess
  var answer = SomeFunction();
  if( answer == null ) {
    answer = "not found";
  }

  // Using the null-coalescing operator:
  var answer = SomeFunction() ?? "not found";
{% endhighlight %}

Which offers a clean, tight and simple way of saying if the answer is null, then use this answer instead.
Maybe we can do the samething in PowerShell?

###### How much would you pay for a null-coalescing operator like C# ?
{% highlight powershell %}
$z == $null ?? "This works!"
echo  "Result: $z"
{% endhighlight %}

>  
{% highlight powershell %}
Result: This works!
{% endhighlight %}

----
###### Of course, it still thinks like powershell so 0, false and $null are all still 'negative'
{% highlight powershell %}
$b == (1 +2 -3) ?? 100
echo  "Result: $b"
{% endhighlight %}

>  
{% highlight powershell %}
Result: 100
{% endhighlight %}

----
###### And regular numbers work nice:
{% highlight powershell %}
$b == (1 +2 +3) ?? 100
echo  "Result: $b"
{% endhighlight %}

>  
{% highlight powershell %}
Result : 6
{% endhighlight %}

----
###### Let's try some more complicated examples
{% highlight powershell %}
function get-null { return $null }

function get-somevalue { return "SomeValue" }

function invoke-sample { 
    # this is what I've wanted for years!
    return = { get-null } ?? { get-somevalue } 
}

echo "Result: $(invoke-sample)"
{% endhighlight %}

>  
{% highlight powershell %}
Result: SomeValue
{% endhighlight %}

----
###### A slight variation
{% highlight powershell %}
function invoke-sample { 
    # this is what I've wanted for years!
    return = ( get-null ) ?? ( get-somevalue )
}

echo "Result: $(invoke-sample)"
{% endhighlight %}

>  
{% highlight powershell %}
Result: SomeValue
{% endhighlight %}

----
###### What does this one do?
{% highlight powershell %}
function invoke-sample { 
    # this is what I've wanted for years!
    return =  get-null  ?? ( get-somevalue ) 
}
{% endhighlight %}

>  
{% highlight powershell %}
echo "Result: $(invoke-sample)"
{% endhighlight %}

>  
{% highlight powershell %}
# perhaps not so surpising...
get-null 
{% endhighlight %}

----
###### We can drop the pretenses; you should have a clue by now.
{% highlight powershell %}
= $null ?? { "still" + "right" } 
{% endhighlight %}

>  
{% highlight powershell %}
stillright
{% endhighlight %}

----
###### A couple more bits of fun:
{% highlight powershell %}
echo (= 0 ? 100 : 200 )
echo (= 1 ? 100 : 200 )
{% endhighlight %}

>  
{% highlight powershell %}
200
100
{% endhighlight %}

----
#### Taking a peek behind the curtain

The ever-so-clever PowerShell enthusiasts will have probably guessed _why_ this works.

It turns out that the power of PowerShell's aliases is actually quite amazing, and when combined with a means 
of evaluating a parameter-regardless if it's an scriptblock or just a value
made it pretty simple to 'extend' assignment with an extra equal sign `=`
   

{% highlight powershell %}
# ---------------------------------------------------------------------------
# Name:   Invoke-Assignment
# Alias:  =
# Author: Garrett Serack (@FearTheCowboy)
# Desc:   Enables expressions like the C# operators: 
#         Ternary: 
#             <condition> ? <trueresult> : <falseresult> 
#             e.g. 
#                status = (age > 50) ? "old" : "young";
#         Null-Coalescing 
#             <value> ?? <value-if-value-is-null>
#             e.g.
#                name = GetName() ?? "No Name";
# 			  
# Ternary Usage:  
#         $status == ($age > 50) ? "old" : "young"
#
# Null Coalescing Usage:
#         $name = (get-name) ? "No Name" 
# ---------------------------------------------------------------------------

# returns the evaluated value of the parameter passed in, 
# executing it, if it is a scriptblock   
function eval($item) {
    if( $item -ne $null ) {
        if( $item -is "ScriptBlock" ) {
            return & $item
        }
        return $item
    }
    return $null
}

# an extended assignment function; implements logic for Ternarys and Null-Coalescing expressions
function Invoke-Assignment {
    if( $args ) {
        # ternary
        if ($p = [array]::IndexOf($args,'?' )+1) {
            if (eval($args[0])) {
                return eval($args[$p])
            } 
            return eval($args[([array]::IndexOf($args,':',$p))+1]) 
        }
        
        # null-coalescing
        if ($p = ([array]::IndexOf($args,'??',$p)+1)) {
            if ($result = eval($args[0])) {
                return $result
            } 
            return eval($args[$p])
        } 
        
        # neither ternary or null-coalescing, just a value  
        return eval($args[0])
    }
    return $null
}

# alias the function to the equals sign (which doesn't impede the normal use of = )
set-alias = Invoke-Assignment -Option AllScope -Description "FearTheCowboy's Invoke-Assignment."
{% endhighlight %}

Now, go forth, and bring terseness and compaction to your scripts!
