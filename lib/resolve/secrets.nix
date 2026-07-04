{ lib }:
let
  inherit (lib)
    attrNames
    concatMap
    filter
    foldl'
    unique
    ;
in
{
  software,
  definedNames,
  providedSecrets,
}:
let

  references = concatMap (
    n:
    map (secret: {
      inherit n secret;
      required = software.${n}.secrets.${secret}.required or false;
      description = software.${n}.secrets.${secret}.description or "";
    }) (attrNames (software.${n}.secrets or { }))
  ) definedNames;

  referencedNames = unique (map (r: r.secret) references);
in
{
  missingRequired = filter (r: r.required && !(providedSecrets ? ${r.secret})) references;

  deadSecrets = filter (s: !(lib.elem s referencedNames)) (attrNames providedSecrets);

  secretsMap = foldl' (
    acc: r:
    acc
    // {
      ${r.secret} = unique (
        (acc.${r.secret} or [ ]) ++ [ (if r.required then "required-by:${r.n}" else "optional-for:${r.n}") ]
      );
    }
  ) { } references;
}
