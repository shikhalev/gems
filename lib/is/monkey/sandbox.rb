# encoding: utf-8

# @yield
def sandbox &block
  lambda do
    $SAFE = 4
    yield
  end.call
end

