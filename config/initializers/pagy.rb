require 'pagy/extras/metadata'
require 'pagy/extras/navs'

Pagy::DEFAULT[:items] = 20
Pagy::DEFAULT[:max_items] = 100
Pagy::DEFAULT[:metadata] = [:count, :page, :items, :pages, :last, :from, :to, :prev, :next]

