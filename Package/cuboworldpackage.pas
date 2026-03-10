{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit CuboWorldPackage;

{$warn 5023 off : no warning about unused units}
interface

uses
  cw_types, cw_chunk, cw_events, cw_storage_intf, cw_storage_mem, 
  cw_generator_intf, cw_generator_flat, cw_world, cuboworld, LazarusPackageIntf;

implementation

procedure Register;
begin
end;

initialization
  RegisterPackage('CuboWorldPackage', @Register);
end.
