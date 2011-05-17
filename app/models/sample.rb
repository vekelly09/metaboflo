class Sample < ActiveRecord::Base
  SAMPLE_TYPES = ['ruminal', 'blood', 'milk', 'urine', 'feces']
  
  scope :location_contains, lambda {|name| where(['building like ? or room like ?', "%#{name}%", "%#{name}%"])}
  search_methods :location_contains
  
  belongs_to :test_subject
  belongs_to :sample
  belongs_to :site
  belongs_to :collected_by, :class_name => 'User'
  
  has_many :samples, :dependent => :destroy
  has_many :experiments, :dependent => :destroy
  
  has_many :cohort_assignments, :as => :assignable, :dependent => :destroy
  has_many :cohorts, :through => :cohort_assignments
  
  before_validation :assign_parent_type
  before_validation :set_test_subject_id
  
  validates :original_amount, :numericality => { :greater_than_or_equal_to => 0 }, :allow_blank => true
  validates :actual_amount, :numericality => { :greater_than_or_equal_to => 0 }, :allow_blank => true

  validate :sample_chronology
  validate :same_parent?
  
  # Required so that Experiments, Samples, and TestSubjects can be displayed in cohorts
  def to_s
    return "#{self.barcode.blank? ? 'No barcode' : self.barcode} (#{sample_type.blank? ? 'No sample type' : sample_type} - #{original_amount.blank? ? 'Unknown amount' : "#{original_amount} #{original_unit}"})"
  end
  
  # sample takes precedence over test subject
  def parent
    self.sample || self.test_subject
  end
  
  def aliquot?
    return !self.sample.blank?
  end
  
  def root
    self.test_subject
  end
  
  # calculates the theoretical amount of this sample = original amount - sum(original amount of each child)
  #
  # assumes that original_unit for this sample and all children are the same
  def theoretical_amount
    theoretical = self.original_amount.to_f
    self.samples.each do |child|
      theoretical -= child.original_amount.to_f
    end
    theoretical
  end
  
  # Return a list of all used sample types
  def Sample.sample_types
    self.select('DISTINCT sample_type').order(:sample_type).all.collect { |s| s.sample_type }
  end
  
  private
    def assign_parent_type
      self.sample_type = self.sample.sample_type if self.sample
    end
  
    # if test subject is nil, sets the test subject to that of parent sample if parent sample exists
    def set_test_subject_id
      self.test_subject_id = self.sample.test_subject_id if self.test_subject_id.blank? && !self.sample.nil?
    end
  
    def sample_chronology
      if (test_subject and test_subject.birthdate and collected_on and test_subject.birthdate > collected_on)
        errors.add(:collected_on, "for sample cannot be before the #{TestSubject.title}'s birthdate")
      end
    end
  
    def same_parent?
      if self.sample && self.sample.test_subject_id != self.test_subject_id
        errors.add(:test_subject_id, "is not the same as that of parent sample")
      end
    end
end
