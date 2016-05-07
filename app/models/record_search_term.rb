class RecordSearchTerm
  attr_reader :where_clause, :where_args, :order
  def initialize(search_term)
    search_term = search_term.downcase
    @where_clause = ""
    @where_args = {}
    build_field_search(search_term)
  end

  def build_field_search(search_term)
    @where_clause << case_insensitive_search(:description)
    @where_args[:description] = starts_or_ends_with(search_term)

    @where_clause << " OR #{case_insensitive_search(:title)}"
    @where_args[:title] = starts_or_ends_with(search_term)

    @where_clause << " OR #{case_insensitive_search(:location)}"
    @where_args[:location] = starts_or_ends_with(search_term)

    @where_clause << " OR #{case_insensitive_search(:source_url)}"
    @where_args[:source_url] = starts_or_ends_with(search_term)

    @where_clause << " OR #{case_insensitive_search(:date)}"
    @where_args[:date] = starts_or_ends_with(search_term)

    @where_clause << " OR #{case_insensitive_search(:hashtag)}"
    @where_args[:hashtag] = starts_or_ends_with(search_term)

    @order = "title asc"
  end

  def starts_or_ends_with(search_term)
    "%" + search_term + "%"
  end

  def case_insensitive_search(field_name)
    "lower(#{field_name}) like :#{field_name}"
  end

end
