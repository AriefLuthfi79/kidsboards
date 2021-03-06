require 'test_helper'

class Uploaded::PhotoCreateTest < ActionDispatch::IntegrationTest
  test 'photo create success' do
    # prepare
    token = login

    # action
    file = fixture_file_upload('test/fixtures/kitten.jpg', 'image/jpeg')
    post '/v1/uploaded/photo', params: { token: token, file: file }

    # check results
    assert_response 200
    json = JSON.parse(response.body)
    # check that record exists
    id = json['id']
    photo = Uploaded::Photo.where(id: id).first
    assert_not_nil photo
    # check that file exists
    url = json['url']
    folder = url.sub(ENV['UPLOAD_HOST'], ENV['UPLOAD_FOLDER'])
    assert_equal File.exist?(folder), true
  end

  test 'photo create wrong params' do
    # prepare
    token = login

    # action 1
    file = fixture_file_upload('test/fixtures/test.mp3', 'audio/mp3')
    post '/v1/uploaded/photo', params: { token: token, file: file }

    # check results
    assert_response 422
    json = JSON.parse(response.body)
    assert_includes json['file'], 'is invalid'

    # action 2
    post '/v1/uploaded/photo', params: { token: token }

    # check results
    assert_response 422
    json = JSON.parse(response.body)
    assert_includes json['file'], 'can\'t be blank'
  end

  test 'photo create fail wrong token' do
    # prepare
    token = Faker::Lorem.characters(10)

    # action 1
    file = fixture_file_upload('test/fixtures/kitten.jpg', 'image/jpeg')
    post '/v1/uploaded/photo', params: { token: token, file: file }

    # check results
    assert_response 401

    # action 2
    file = fixture_file_upload('test/fixtures/kitten.jpg', 'image/jpeg')
    post '/v1/uploaded/photo', params: { file: file }

    # check results
    assert_response 401
  end
end
