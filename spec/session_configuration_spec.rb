describe NSURLSessionConfiguration do
  %w[defaultSessionConfiguration ephemeralSessionConfiguration].each do |method|
    it 'should not raise runtime error' do
      lambda { NSURLSessionConfiguration.send(method) }.should.not.raise RuntimeError
    end
  end
end
