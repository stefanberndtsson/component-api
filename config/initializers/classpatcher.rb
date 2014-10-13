class String
  def norm
    decomposed = Unicode.nfkd(self)
    Unicode.downcase(decomposed)
  end
end

class NilClass
  def norm
    nil
  end
end
