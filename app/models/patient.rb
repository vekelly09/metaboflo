class Patient < ActiveRecord::Base
  belongs_to :site
  
  has_many :samples, :dependent => :destroy
  
  has_many :cohort_assignments, :as => :assignable, :dependent => :destroy
  has_many :cohorts, :through => :cohort_assignments
  
  has_many :medications
  has_many :patient_evaluations
  has_many :lab_tests, :order => 'collected_at ASC'
  
  validates_presence_of :code, :site_id
  validates_inclusion_of :gender, :in => ['Male', 'Female'], :allow_blank => true, :message => 'must be either Male or Female'
  
  validates_length_of  :first_initial, :maximum => 1, :message => "should be at most 1 character"
  validates_length_of  :middle_initial, :maximum => 1, :message => "should be at most 1 character"
  validates_length_of  :last_initial, :maximum => 1, :message => "should be at most 1 character"
  
  def name
    "#{self.first_initial} #{self.middle_initial} #{self.last_initial}".gsub(/\s+/, " ").strip
  end
  
  # Required so that Experiments, Samples, and Patients can be displayed in cohorts
  def to_s
    return self.name
  end
  
end
