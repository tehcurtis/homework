class SomeController < ApplicationController
  def show_candidates
    s_key = params[:sort].blank? ? "All Candidates" : params[:sort];
    @open_jobs = Job.all_open_new(current_user.organization)
    #if current_user.old_role == "admin" || current_user.old_role == "sys.admin"
     #changed based on new model(24/11/11)
    #if current_user.role(:name =>"admin") || current_user.role(:name =>"sys.admin")
   if current_user.has_permission?('view_candidates')
      if s_key == "All Candidates"
        @candidates = current_user.organization.candidates.all(:is_deleted => false, :is_completed => true)
      elsif s_key == "Candidates Newest -> Oldest"
        @candidates = current_user.organization.candidates.all(:is_deleted => false, :is_completed => true, :order => [:created_at.desc])
      elsif s_key == "Candidates Oldest -> Newest"
        @candidates = current_user.organization.candidates.all(:is_deleted => false, :is_completed => true, :order => [:created_at.asc])
      elsif s_key == "Candidates A -> Z"
        @candidates = current_user.organization.candidates.all(:is_deleted => false, :is_completed => true, :order => [:created_at.asc]).sort! { |a, b| a.last_name <=> b.last_name }
      elsif s_key == "Candidates Z -> A"
        @candidates = current_user.organization.candidates.all(:is_deleted => false, :is_completed => true, :order => [:created_at.asc]).sort! { |a, b| a.last_name <=> b.last_name }.reverse
      end
    else
      @job_contacts = JobContact.all(:user_id => current_user.id)
      jobs          = []
      @candidates   = []
      unless @job_contacts.blank?
        @job_contacts.each do |jobs_contacts|
          @job = Job.first(:id => jobs_contacts.job_id, :is_deleted => false)
          jobs << @job
        end
        jobs.each do |job|
         unless job.blank?
          candidate_jobs = CandidateJob.all(:job_id => job.id)
          unless candidate_jobs.blank?
            candidate_jobs.each do |cj|
              candidate = cj.candidate
              if candidate.is_deleted == false && candidate.is_completed == true && candidate.organization_id == current_user.organization_id
                found = false
                unless @candidates.blank?
                  @candidates.each do |cand|
                    if cand.email_address == candidate.email_address
                      found = true
                    end
                  end
                end
                if found == false
                  @candidates << candidate
                end
              end
              if s_key == "Candidates Newest -> Oldest"
                @candidates = @candidates.sort_by { |c| c.created_at }
              elsif s_key == "Candidates Oldest -> Newest"
                @candidates = @candidates.sort_by { |c| c.created_at }.reverse
              elsif s_key == "Candidates A -> Z"
                @candidates = @candidates.sort_by { |c| c.created_at }.sort! { |a, b| a.last_name <=> b.last_name }
              elsif s_key == "Candidates Z -> A"
                @candidates = @candidates.sort_by { |c| c.created_at }.sort! { |a, b| a.last_name <=> b.last_name }.reverse
              end
            end
          end
         end
        end
      end
    end
    render :partial => "candidates_list", :locals => { :@candidates => @candidates, :open_jobs => @open_jobs }, :layout => false
  end
end
