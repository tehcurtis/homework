class CandidateJob
  def self.jobs_for_active_candidates(job_ids)
    where(:job_id => job_ids).
      eager_load(:candidate).
      where("#{Candidate.table_name}.is_deleted = ? AND #{Candidate.table_name}.is_completed = ? AND #{Candidate.table_name}.organization_id = ?",  false, true, current_user.organization_id)
  end
end
