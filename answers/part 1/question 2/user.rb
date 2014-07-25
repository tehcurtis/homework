class User
  has_many :job_contacts

  def job_contacts_ids
    job_contacts.eager_load(:job).where("jobs.is_deleted = ?", false).pluck(:job_id)
  end
end
