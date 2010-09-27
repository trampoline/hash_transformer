class HashTransformer

  class HashTransformerDsl
    attr_reader :transforms

    def initialize(transforms)
      @transforms = transforms
    end

    def configure(&proc)
      self.instance_eval(&proc)
    end

    def delete_key(key)
      transforms << DeleteKeyTransform.new(key)
    end

    def map_key(key, to)
      transforms << MapKeyTransform.new(key, to)
    end

    def transform_hash(key, &proc)
      transforms << HashTransformerTransform.new(key, &proc)
    end
  end

  class DeleteKeyTransform
    attr_reader :key

    def initialize(key)
      @key = key
    end

    def transform(h)
      h.delete(@key)
      h
    end
  end

  class MapKeyTransform
    attr_reader :key
    attr_reader :to

    def initialize(key, to)
      @key = key
      @to = to
    end

    def transform(h)
      if h.has_key?(@key)
        v = h.delete(@key)
        raise "can't map key #{key.inspect} to #{to.inspect} : target key exists" if h.has_key?(@to)
        h[@to] = v
      end
      h
    end
  end

  class HashTransformerTransform
    attr_reader :key
    attr_reader :hash_transformer

    def initialize(key, &proc)
      @key = key
      @hash_transformer = HashTransformer.new(&proc)
    end

    def transform(h)
      h[key] = @hash_transformer.transform(h[key])
    end
  end

  attr_reader :transforms

  def initialize(&proc)
    @transforms = []
    HashTransformerDsl.new(@transforms).configure(&proc)
  end

  def transform(h)
    transforms.reduce(h){|r,transform| transform.transform(r) ; r}
  end
end
