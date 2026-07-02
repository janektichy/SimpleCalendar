module Events
  class VirtualOccurrence < SimpleDelegator
    attr_reader :starts_at, :ends_at, :occurrence_key

    def initialize(event, starts_at:, ends_at:, occurrence_key:)
      super(event)
      @starts_at = starts_at
      @ends_at = ends_at
      @occurrence_key = occurrence_key
    end

    def id
      occurrence_key
    end

    def to_model
      __getobj__
    end

    def persisted?
      __getobj__.persisted?
    end
  end
end
