# Redmine - project management software
# Copyright (C) 2006-2016  Jean-Philippe Lang
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

class IssueStatusesController < ApplicationController
  layout 'admin'

  before_filter :require_admin, :except => :index
  before_filter :require_admin_or_api_request, :only => :index
  accept_api_auth :index

  def index
    @issue_statuses = IssueStatus.sorted.to_a
    respond_to do |format|
      format.html { render :layout => false if request.xhr? }
      format.api
    end
  end

  def new
    @issue_status = IssueStatus.new
  end

  def create
    @issue_status = IssueStatus.new(params[:issue_status])
    if @issue_status.save
      flash[:notice] = l(:notice_successful_create)
      redirect_to issue_statuses_path
    else
      render :action => 'new'
    end
  end

  def edit
    @issue_status = IssueStatus.find(params[:id])
  end

  def update
    @issue_status = IssueStatus.find(params[:id])
    if @issue_status.update_attributes(params[:issue_status])
      respond_to do |format|
        format.html {
          flash[:notice] = l(:notice_successful_update)
          redirect_to issue_statuses_path(:page => params[:page])
        }
        format.js { render :nothing => true }
      end
    else
      respond_to do |format|
        format.html { render :action => 'edit' }
        format.js { render :nothing => true, :status => 422 }
      end
    end
  end

  def destroy
    IssueStatus.find(params[:id]).destroy
    redirect_to issue_statuses_path
  rescue
    flash[:error] = l(:error_unable_delete_issue_status)
    redirect_to issue_statuses_path
  end

  def update_issue_done_ratio
    if request.post? && IssueStatus.update_issue_done_ratios
      flash[:notice] = l(:notice_issue_done_ratios_updated)
    else
      flash[:error] =  l(:error_issue_done_ratios_not_updated)
    end
    redirect_to issue_statuses_path
  end
end
