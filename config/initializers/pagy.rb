require 'pagy/extras/metadata'

Pagy::DEFAULT[:items] = 20
Pagy::DEFAULT[:max_items] = 100
Pagy::DEFAULT[:metadata] = [:count, :page, :items, :pages, :last, :from, :to, :prev, :next]

