require File.join(File.dirname(__FILE__), 'helper')

class TestElasticSearchable < Test::Unit::TestCase
  ActiveRecord::Schema.define(:version => 1) do
    create_table :posts, :force => true do |t|
      t.column :title, :string
      t.column :body, :string
    end
  end

  class Post < ActiveRecord::Base
    elastic_searchable
  end

  context 'Post class with default elastic_searchable config' do
    setup do
      @clazz = Post
    end
    should 'respond to :search' do
      assert @clazz.respond_to?(:search)
    end
    should 'define index_name' do
      assert_equal 'test_elastic_searchable-post', @clazz.index_name
    end
  end

  context 'Post.create_index' do
    setup do
      Post.create_index
      @status = ElasticSearchable.searcher.index_status Post.index_name
    end
    should 'have created index' do
      assert @status['ok']
    end
  end

  context 'creating new instance' do
    setup do
      Post.delete_all
      @post = Post.create :title => 'foo', :body => "bar"
      Post.create_index
    end
    context 'searching for results' do
      setup do
        @results = Post.search 'foo'
      end
      should 'find created object' do
        assert_equal @post, @results.first
      end
      should 'be paginated' do
        assert_equal 1, @results.total_entries
      end
    end
  end
end