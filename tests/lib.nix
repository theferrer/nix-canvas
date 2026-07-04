{ canvasLib }:
let
  conf = {
    canvas = {
      resolved = {
        software = {
          kitty = { };
        };
        graphical = true;
        sessionProtocol = "wayland";
      };
      machine.formFactor = "laptop";
    };
  };
in
{
  testIsActive = {
    expr = canvasLib.isActive conf "kitty";
    expected = true;
  };

  testIsNotActive = {
    expr = canvasLib.isActive conf "emacs";
    expected = false;
  };

  testIsGraphical = {
    expr = canvasLib.isGraphical conf;
    expected = true;
  };

  testIsWayland = {
    expr = canvasLib.isWayland conf;
    expected = true;
  };

  testIsX11 = {
    expr = canvasLib.isX11 conf;
    expected = false;
  };

  testIsFormFactor = {
    expr = canvasLib.isFormFactor conf [
      "laptop"
      "handheld"
    ];
    expected = true;
  };

  testMkIfActiveCondition = {
    expr = (canvasLib.mkIfActive conf "kitty" { }).condition;
    expected = true;
  };

  testSpecVocabularyExported = {
    expr = canvasLib.spec.capabilities ? terminal && canvasLib.spec.capabilities ? desktop;
    expected = true;
  };
}
