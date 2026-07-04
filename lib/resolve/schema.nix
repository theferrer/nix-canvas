{
  supportedSchema = 1;

  args = {
    wants = "listOfStr";
    look = "nullOrStr";
    use = "attrsOfNullOrStr";
    extra = "listOfStr";
    exclude = "listOfStr";
    secrets = "attrsOfStr";
    graphical = "nullOrBool";
  };

  catalog = {
    schemaVersion = "int";
    capabilities = "attrs";
    software = "attrs";
    wants = "attrs";
    looks = "attrs";
  };

  software = {
    package = "any";
    provides = "listOfStr";
    needs = "listOfStr";
    needsCapabilities = "listOfStr";
    conflicts = "listOfStr";
    sessionProtocol = "protocol";
    homeModule = "any";
    secrets = "attrs";
    description = "str";
  };

  secretRequirement = {
    required = "bool";
    description = "str";
  };

  capability = {
    description = "str";
    requiresGraphical = "bool";
  };

  want = {
    description = "str";
    capabilities = "listOfStr";
    software = "listOfStr";
    includes = "listOfStr";
  };

  look = {
    use = "attrsOfStr";
    style = "nullOrStr";
  };
}
