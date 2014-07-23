# Redmine default issues plugin

Lets you create default issue with default subissues per role that will be assigned to a newly added user to the project (having a specified role).

# Requirements

Developed & tested on Redmine 2.5.1

# Installation

1. Go to your Redmine installation's plugins/ directory.
2. `git clone https://github.com/efigence/redmine_default_issues && cd ..`
3. `bundle exec rake redmine:plugins:migrate NAME=redmine_default_issues RAILS_ENV=production`
4. Restart Redmine.
5. Add proper permissions and module tab in redmine settings.

# Usage
Example of use in: 
[Documentation](https://github.com/efigence/redmine_default_issues/edit/master/Documentation.md)
# License

    Redmine context menu log time to project link plugin
    Copyright (C) 2014  efigence S.A.

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
