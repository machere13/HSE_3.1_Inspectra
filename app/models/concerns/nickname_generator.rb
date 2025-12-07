module NicknameGenerator
  CODE_METAPHOR_PREFIXES = [
    'Code', 'Bug', 'Syntax', 'Debug', 'Byte', 'Bit', 'Stack', 'Heap', 'Queue', 'Tree',
    'Node', 'Array', 'Hash', 'List', 'Set', 'Map', 'Graph', 'Loop', 'Recursion', 'Lambda',
    'Function', 'Class', 'Object', 'Method', 'Variable', 'Constant', 'String', 'Integer',
    'Float', 'Boolean', 'Null', 'Void', 'Return', 'Break', 'Continue', 'Async', 'Promise',
    'Callback', 'Event', 'Stream', 'Buffer', 'Cache', 'Cookie', 'Session', 'Token', 'Key',
    'Value', 'Index', 'Pointer', 'Reference', 'Instance', 'Static', 'Public', 'Private',
    'Protected', 'Abstract', 'Interface', 'Trait', 'Module', 'Package', 'Import', 'Export',
    'Require', 'Include', 'Extend', 'Inherit', 'Override', 'Polymorph', 'Encapsulate',
    'Abstraction', 'Inheritance', 'Composition', 'Aggregation', 'Dependency', 'Association'
  ].freeze

  CODE_METAPHOR_SUFFIXES = [
    'Ninja', 'Master', 'Wizard', 'Hunter', 'Warrior', 'Knight', 'Guardian', 'Defender',
    'Builder', 'Creator', 'Maker', 'Designer', 'Architect', 'Engineer', 'Developer',
    'Coder', 'Programmer', 'Hacker', 'Guru', 'Expert', 'Pro', 'Elite', 'Legend',
    'Hero', 'Champion', 'Ace', 'Star', 'Genius', 'Savant', 'Virtuoso', 'Maestro',
    'Pioneer', 'Trailblazer', 'Innovator', 'Visionary', 'Strategist', 'Tactician',
    'Solver', 'Fixer', 'Optimizer', 'Refactorer', 'Debugger', 'Tester', 'Validator',
    'Executor', 'Runner', 'Processor', 'Handler', 'Manager', 'Controller', 'Router',
    'Service', 'Repository', 'Factory', 'Builder', 'Singleton', 'Observer', 'Mediator'
  ].freeze

  def generate_code_metaphor_name
    prefix = CODE_METAPHOR_PREFIXES.sample
    suffix = CODE_METAPHOR_SUFFIXES.sample
    number = rand(100..9999)
    
    "#{prefix}#{suffix}#{number}"
  end

  def generate_code_metaphor_name!
    loop do
      generated_name = generate_code_metaphor_name
      unless self.class.exists?(name: generated_name)
        self.name = generated_name
        break
      end
    end
  end
end

