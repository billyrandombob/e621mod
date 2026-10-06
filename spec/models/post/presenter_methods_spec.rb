# frozen_string_literal: true

require "rails_helper"

RSpec.describe Post do
  include_context "as admin"

  describe "PresenterMethods" do
    describe "#pretty_rating" do
      it "returns 'General' for rating g" do
        expect(create(:post, rating: "g").pretty_rating).to eq("General")
      end

      it "returns 'Mature' for rating m" do
        expect(create(:post, rating: "m").pretty_rating).to eq("Mature")
      end

      it "returns 'Unrated' for rating u" do
        expect(create(:post, rating: "u").pretty_rating).to eq("Unrated")
      end
    end

    describe "#visible_comment_count" do
      let(:member) { create(:user) }

      it "returns the comment_count when comments are not disabled" do
        post = create(:post)
        post.update_columns(comment_count: 5)
        expect(post.visible_comment_count(member)).to eq(5)
      end

      it "returns 0 when comments are disabled and the user is not staff" do
        post = create(:post)
        post.update_columns(comment_count: 5, is_comment_disabled: true)
        expect(post.visible_comment_count(member)).to eq(0)
      end

      it "returns the comment_count when comments are disabled but the user is staff" do
        post = create(:post)
        post.update_columns(comment_count: 5, is_comment_disabled: true)
        expect(post.visible_comment_count(CurrentUser.user)).to eq(5)
      end
    end

    describe "#mark_as_translated" do
      it "adds translated and removes translation_request when neither flag is set" do
        post = create(:post)
        post.update!(tag_string: "#{post.tag_string} translation_request")
        post.mark_as_translated("translation_check" => "0", "partially_translated" => "0")
        expect(post.tag_array).to include("translated")
        expect(post.tag_array).not_to include("translation_request")
      end

      it "adds translation_request and removes translated when translation_check is truthy" do
        post = create(:post)
        post.update!(tag_string: "#{post.tag_string} translated")
        post.mark_as_translated("translation_check" => "1", "partially_translated" => "0")
        expect(post.tag_array).to include("translation_request")
        expect(post.tag_array).not_to include("translated")
      end

      it "adds translation_request and removes translated when partially_translated is truthy" do
        post = create(:post)
        post.update!(tag_string: "#{post.tag_string} translated")
        post.mark_as_translated("translation_check" => "0", "partially_translated" => "1")
        expect(post.tag_array).to include("translation_request")
        expect(post.tag_array).not_to include("translated")
      end
    end
  end
end
