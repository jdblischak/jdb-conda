#!/usr/bin/env python

# I am getting too many email notifications from GitHub. This makes it difficult
# to know when I am specifically requested via @jdblischak or @conda-forge/r to
# help with a particular issue. I have taken multiple steps to reduce the number
# of notifications I receive.
#
# 1. Stop watching the team @conda-forge/staged-recipes. Since I can only really
# help with R recipes, it is better to wait until mentioned via @conda-forge/r
# or my username.
#
# https://github.com/orgs/conda-forge/teams/staged-recipes
#
# 2. This script unwatches all the conda-forge R feedstocks. Thus I will only be
# notified if directly mentioned.
#
# 3. Note that I could also stop watching automatically or stop receiving email
# notifications for watching by changing my settings:
# https://github.com/settings/notifications. I haven't done this yet since I'm
# afraid I might miss something. Thus I'd rather opt out rather than opt in.

# https://github.com/watching
# https://github.com/settings/notifications
# https://developer.github.com/v3/activity/watching/
# https://github.com/conda-forge/conda-forge.github.io/blob/master/scripts/watch_only_my_feedstocks.py
# https://pygithub.readthedocs.io/en/latest/github_objects/AuthenticatedUser.html?highlight=remove_from_subscriptions#github.AuthenticatedUser.AuthenticatedUser.remove_from_watched
# https://guides.github.com/features/issues/#notifications

# Note: I wanted to use remove_from_watched() over remove_from_subscriptions() because the
# latter uses a legacy API endpoint. However, the newer endpoint failed with '404 Not Found' both for remove_from_watched() and gh.
#
# gh("DELETE /repos/:owner/:repo/subscription", owner = "conda-forge", repo = "r-dbscan-feedstock")
# ## Error in gh("DELETE /repos/:owner/:repo/subscription", owner = "conda-forge",  :
# ##   GitHub API error (404): 404 Not Found
# ##   Not Found

import github
import os
import re

gh_token = os.environ['GH_TOKEN']
gh = github.Github(gh_token)
gh_me = gh.get_user()

assert gh_me.login == 'jdblischak', \
    'Invalid username: {}'.format(gh_me.login)

watched = gh_me.get_watched()
print('You are watching {} repositories.'.format(watched.totalCount))

re_feedstock = re.compile('^r-.+-feedstock$')

#repo = watched[0]

skip = ['r-feedstock',
        'r-base-feedstock',
        'r-git2r-feedstock',
        'r-knitr-feedstock',
        'r-rmarkdown-feedstock',
        'r-workflowr-feedstock']

for repo in watched:
    n = repo.name
    if repo.owner.name == 'conda-forge' and \
       re_feedstock.match(n) and \
       n not in skip:
        print(n)
        # I tried using the current API endpoint, but this failed both for
        # pygithub and using the R package gh.
        #
        # gh_me.remove_from_watched(repo)
        #
        # Thus I used the legacy endpoint:
        gh_me.remove_from_subscriptions(repo)
        print('Stopped watching {}'.format(repo.full_name))
