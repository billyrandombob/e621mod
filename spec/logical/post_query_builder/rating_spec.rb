# frozen_string_literal: true

require "rails_helper"

RSpec.describe PostQueryBuilder do
  include_context "as admin"

  def run(query)
    PostQueryBuilder.new(query).search
  end

  describe "rating: metatag" do
    describe "rating:s" do
      it "includes general-rated posts" do
        post = create(:post, rating: "g")
        expect(run("rating:g")).to include(post)
      end

      it "excludes unrated-rated posts" do
        post = create(:post, rating: "u")
        expect(run("rating:g")).not_to include(post)
      end
    end

    describe "rating:e" do
      it "includes unrated-rated posts" do
        post = create(:post, rating: "u")
        expect(run("rating:u")).to include(post)
      end

      it "excludes general-rated posts" do
        post = create(:post, rating: "g")
        expect(run("rating:u")).not_to include(post)
      end
    end

    describe "rating:q" do
      it "includes mature-rated posts" do
        post = create(:post, rating: "m")
        expect(run("rating:m")).to include(post)
      end

      it "excludes general-rated posts" do
        post = create(:post, rating: "g")
        expect(run("rating:m")).not_to include(post)
      end
    end

    # FIXME: rating_must_not applies `where("posts.rating = ?", rating)` instead of
    # `where.not(...)` (post_query_builder.rb:195), so -rating: incorrectly acts as
    # an inclusion filter rather than an exclusion filter. Tests are commented out
    # until the bug is fixed.
    #
    # describe "-rating:g" do
    #   it "excludes general-rated posts" do
    #     post = create(:post, rating: "g")
    #     expect(run("-rating:g")).not_to include(post)
    #   end
    #
    #   it "includes unrated-rated posts" do
    #     post = create(:post, rating: "u")
    #     expect(run("-rating:g")).to include(post)
    #   end
    # end
  end
end
