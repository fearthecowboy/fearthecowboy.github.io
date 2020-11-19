---
layout: post
title: "The Laws of Software Installation"
description: "Guidance around software installation ideas"
category: informational
tags: [SDII]
---

# Establishing an Ecosystem That Works Together

I started thinking about how all of this fits together and how we (as an
ecosystem) need to be able to work together, and &mdash; more importantly
&mdash; still allow different systems to work how they please.

Many years ago, [Kim Cameron](http://www.identityblog.com/) came up with a list
of [*7 Laws of Identity*](http://www.identityblog.com/?p=352/). They outline
some core fundamental principles that any Identity system should follow to
ensure that everyone's (users, identity providers, and relying parties)
security is maximized.

It occurred to me that concepts from the Laws could be recycled in a way that
reflects how we can define the general parameters for an installation
ecosystem.

## 1. User Control and Consent

Users must always be able to make the ultimate decisions about their system,
and installers must never do unauthorized actions without the user's consent.
Essentially, we really want to ensure that changes that the user doesn't want
aren't being applied to their systems. This means that an installer should
always provide a clear and accurate description of the product being installed,
and ensure that the user is in control of their systems. User interfaces or
tools that obscure or break this trust with the user should be avoided.
Ideally, user interfaces should strive for some amount of minimalism, instead
of serving up a collection of pedantic screens which users tediously press
'Next' through. Less UI means that users are far more likely to pay attention
to what is said.

> *Personal opinion:* I guess at the same time, I should point out a particular
> gripe of mine, especially with open source software installation on Windows.
> The proliferation of EULAs and Licenses masquerading as EULAs in the
> installation process should stop. Many OSS licenses don't actually have any
> requirement for the end user to agree to the terms of them before
> installation, so please stop asking for people to 'agree' just to make it
> look like you have a 'professional' installer.
>
> If you *actually* have a requirement to record an acceptance of license,
> perhaps you should be doing that upon first use (or whatever activity
> actually requires the acceptance of the license).

## 2. Minimal Impact for a Constrained Use

Changes to a system should aim to offer the least amount of disruption to the
system. Installing unnecessary or unwanted components adds to bloat, and will
increase the potential attack surface for malware.

> *Personal opinion:* There is a category of software out there that has opted
> to provide their software free, but heavily &mdash; and often with great
> vigilance &mdash; attempts to install toolbars, add-ons, or other pieces of
> trash software that serve only to funnel advertising to the user. Others nag
> the user to change their default search settings or their browser home page
> for similar purposes. These behaviors are abusive to customers, and should be
> avoided at all costs.

## 3. Pluralism of Operators and Technologies

The ecosystem should easily support many different technologies. There is no
one-size-fits-all answer. Software comes in all shapes and sizes. Any
well-behaved individual packaging or installation technology should be welcome
to participate. Choosing one technology over another should be left to the
publisher. Pushing this to the logical ends means that any attempt to unify
these should permit and encourage use of any part of the ecosystem.

## 4. Transparency, Accountability, and Reversability

Installation technologies should never obfuscate *what* is being done, and
should never place the system in a state that cannot be undone. Again, keeping
in mind that the target system belongs to the user, not the publisher, end
users should be able to expect that uninstallation should succeed without issue
or require any additional work to clean up.

> *Personal opinion:* On a slightly tangential note, I'd like to talk about
> rebooting the system. Windows Installers seem to be over-eager to reboot the
> OS, either on installation or uninstallation. Now, there is a very small
> class of software that can actually justify having to reboot the system. But
> 99%+ of software should be able to deal with file conflicts, proper setup,
> managing their running processes or services, manipulating locked files,
> removing temporary files, and all of those other reasons that you think you
> need to reboot the system in order to finish the work. If you need help on
> doing this, ask. You'll be doing everyone a great service.

## 5. Flexibility of Installation Scope

*Ideally*, a given package should be able to install into different
installation scopes (OS/Global scope, Restricted/User scope, and
Local/Sandboxed scope) and support installation into online and offline (VM
Images) systems. Packaging systems should consider how they can help products
to be fully installed in these scopes.

## 6. Configuration Is Not Installation

Software installers on Windows have, since time began, been conflating
configuration with installation. This approach introduces several painful
problems into the software installation process:

*   It increases the amount of UI during installation, which only leads to
    additional confusion for the end user.
*   Users may not know the answers to configuration questions, and are now
    blocked until they can find answers.
*   Configuration during installation is nearly always significantly different
    from configuring (or 're-configuring') the product *after* installation.
    Again, this is confusing to the user.
*   Migrating a working configuration to another system is harder when you have
    to configure during installation. Configuration should be easily portable
    between installations.
*   It increases friction for end users who are trying to automate the
    installation of software for a large number of systems.

Really, don't be that guy.

## 7. Respect the Resources of the Target System

Software publishers need to respect the system on which their software is being
installed. You don't own that system, the end user does. Here are some common
scenarios that can be disrespectful:

*   **Launching directly from the installer.** Installation should not be
    considered a good opportunity to launch your application. Similar to
    configuration issues, this is frustrating to end users who are looking to
    automate the installation, and can introduce confusion for users who may
    not have expected that.
*   **Automatically starting software at system start.** The proliferation of
    software that insists on starting up with the OS automatically is getting
    out of control. Software that wishes to launch at start-up should get
    explicit *opt-in* consent from the user (after the user has launched the
    application at least once), not require the user to hunt down the option
    from a sea of configuration settings to disable it. Oh, and *not* providing
    a method to trivially disable auto-start is very bad.
*   **Checking for software updates.** There are two acceptable methods for
    automatically checking for software updates:
    *   **Preferred:** checking from within the application itself (i.e. at
        startup) and elegantly handling update and restart.
    *   **Acceptable:** Launching an update checker *via a scheduled task*,
        checking, and then exiting.
    *   **Wrong:** Auto-starting a background or tray application to constantly
        check for updates.

> *Personal opinion:* This last one is particularly frustrating. Since Windows
> doesn't currently have a built-in 3rd party update service (like Windows
> Update) that will periodically check for updates, download, and install them,
> many companies have resorted to running bloated, wasteful apps in the
> background, waiting for updates. This is terribly disrespectful to the end
> user's system, and offers absolutely nothing of value to the user that a
> scheduled task wouldn't accomplish with less effort.
     
## 8. Consistent Experience Across Contexts

Finally, regardless of underlying technology, there should be a common set of
commands, tools, and processes that allow users to install any software in the
way that they would like. Currently, we see that individual installation
technologies are all headed in different directions, which makes automating the
installation of some pieces of software a nightmare. We as a community need to
have the ability to bring all of these pieces of software together without
having to manually script each individual combination.

---

*Garrett Serack* ([@fearthecowboy](https://github.com/fearthecowboy))
