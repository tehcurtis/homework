class Candidate
  class << self
    def for_organization(organization, sort_by)
      organization.candidates.where(:is_deleted => false, :is_completed => true).order(order_str(sort_by))
    end

    def for_ids(candidate_ids, sort_by)
      where(id: candidate_ids).order(order_str(sort_by))
    end

    private

    def order_str(sort_by)
      key = sort_by.blank? ? "All Candidates" : sort_by
      {
        'All Candidates' => 'created_at desc', # just since that's what most people would want in this situation
        'Candidates Newest -> Oldest' => 'created_at desc',
        'Candidates Oldest -> Newest' => 'created_at asc',
        'Candidates A -> Z' => 'last_name asc',
        'Candidates Z -> A' => 'last_name desc'
      }[key]
    end
  end
end
