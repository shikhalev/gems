# encoding: utf-8

# @yield
def sandbox &block
  lambda do
    $SAFE = 3
    yield
  end.call
end

