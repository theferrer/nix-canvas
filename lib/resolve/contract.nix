{ lib }:
let
  inherit (lib)
    attrNames
    attrValues
    concatMap
    concatStringsSep
    filter
    isAttrs
    optional
    all
    ;
  schema = import ./schema.nix;

  shapeOk = {
    int = builtins.isInt;
    str = builtins.isString;
    bool = builtins.isBool;
    attrs = isAttrs;
    listOfStr = v: builtins.isList v && all builtins.isString v;
    nullOrStr = v: v == null || builtins.isString v;
    nullOrBool = v: v == null || builtins.isBool v;
    attrsOfStr = v: isAttrs v && all builtins.isString (attrValues v);
    attrsOfNullOrStr = v: isAttrs v && all (x: x == null || builtins.isString x) (attrValues v);
    protocol = v: v == null || v == "wayland" || v == "x11";
    any = _: true;
  };

  shapeName = {
    int = "an integer";
    str = "a string";
    bool = "a boolean";
    attrs = "an attribute set";
    listOfStr = "a list of strings";
    nullOrStr = "null or a string";
    nullOrBool = "null or a boolean";
    attrsOfStr = "an attribute set of strings";
    attrsOfNullOrStr = "an attribute set of null-or-string values";
    protocol = "null, \"wayland\" or \"x11\"";
    any = "anything";
  };

  fieldAssertions =
    kind: spec: name: entry:
    map (field: {
      assertion = false;
      message = "canvas: ${kind} '${name}' declares unknown field '${field}'; known fields: ${concatStringsSep ", " (attrNames spec)}";
    }) (filter (f: !(spec ? ${f})) (attrNames entry))
    ++ concatMap (
      field:
      optional (entry ? ${field} && !(shapeOk.${spec.${field}} entry.${field})) {
        assertion = false;
        message = "canvas: ${kind} '${name}' field '${field}' must be ${shapeName.${spec.${field}}}";
      }
    ) (attrNames spec);

  entriesAssertions =
    kind: spec: entries:
    concatMap (
      name:
      if isAttrs entries.${name} then
        fieldAssertions kind spec name entries.${name}
      else
        [
          {
            assertion = false;
            message = "canvas: ${kind} '${name}' must be an attribute set";
          }
        ]
    ) (attrNames entries);

  secretRequirementAssertions =
    entries:
    concatMap (
      name:
      let
        secrets = entries.${name}.secrets or { };
      in
      if isAttrs entries.${name} && isAttrs secrets then
        entriesAssertions "secret requirement of software '${name}'" schema.secretRequirement secrets
      else
        [ ]
    ) (attrNames entries);
in
{
  catalog,
  args,
}:
let

  sectionOf = name: if isAttrs (catalog.${name} or { }) then catalog.${name} or { } else { };
  schemaVersion = catalog.schemaVersion or schema.supportedSchema;
in
{
  assertions =
    concatMap (
      name:
      optional (!(shapeOk.${schema.args.${name}} args.${name})) {
        assertion = false;
        message = "canvas: resolve argument '${name}' must be ${shapeName.${schema.args.${name}}}";
      }
    ) (attrNames schema.args)
    ++ (
      if !(isAttrs catalog) then
        [
          {
            assertion = false;
            message = "canvas: the catalog must be an attribute set";
          }
        ]
      else
        map (field: {
          assertion = false;
          message = "canvas: catalog declares unknown field '${field}'; known fields: ${concatStringsSep ", " (attrNames schema.catalog)}";
        }) (filter (f: !(schema.catalog ? ${f})) (attrNames catalog))
        ++ concatMap (
          field:
          optional (catalog ? ${field} && !(shapeOk.${schema.catalog.${field}} catalog.${field})) {
            assertion = false;
            message = "canvas: catalog field '${field}' must be ${shapeName.${schema.catalog.${field}}}";
          }
        ) (attrNames schema.catalog)
        ++ optional (builtins.isInt schemaVersion && schemaVersion != schema.supportedSchema) {
          assertion = false;
          message = "canvas: this palette targets catalog schemaVersion ${toString schemaVersion}, but this canvas supports version ${toString schema.supportedSchema}";
        }
        ++ entriesAssertions "software" schema.software (sectionOf "software")
        ++ secretRequirementAssertions (sectionOf "software")
        ++ entriesAssertions "capability" schema.capability (sectionOf "capabilities")
        ++ entriesAssertions "want" schema.want (sectionOf "wants")
        ++ entriesAssertions "look" schema.look (sectionOf "looks")
    );
}
