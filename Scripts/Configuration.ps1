<#
-> Running this script with admin rights
#>
<#
If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{   
    $arguments = "& '" + $myinvocation.mycommand.definition + "'"
    Start-Process powershell -Verb runAs -ArgumentList $arguments
    Break
}
#>
$scriptLocationOnThisPC = split-path -parent $MyInvocation.MyCommand.Definition
$configFilesLocationOnThisPC = "$scriptLocationOnThisPC\Config files"

Add-Type -AssemblyName PresentationFramework
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") 

[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        Title="File Organizer" Height="620" Width="728" FontFamily="Book Antiqua" FontSize="14" ResizeMode="CanMinimize" WindowStyle="ToolWindow">
    <Window.Background>
        <ImageBrush ImageSource="$configFilesLocationOnThisPC\background.png" Stretch="Fill"/>
    </Window.Background>
    <Grid Height="390" Margin="70,0,56,0" VerticalAlignment="Bottom">
        <Grid.RowDefinitions>
            <RowDefinition/>
        </Grid.RowDefinitions>
        <Grid.ColumnDefinitions>
            <ColumnDefinition/>
        </Grid.ColumnDefinitions>
        <Border BorderThickness="1" BorderBrush="White" HorizontalAlignment="Left" Height="180" Margin="7,-44,0,0" VerticalAlignment="Top" Width="540">
            <Border.Background>
                <SolidColorBrush Color="White" Opacity="0.7"/>
            </Border.Background>
        </Border>

        <Border BorderThickness="1" BorderBrush="White" HorizontalAlignment="Left" Height="100" Margin="7,147,0,0" VerticalAlignment="Top" Width="540">
            <Border.Background>
                <SolidColorBrush Color="White" Opacity="0.7"/>
            </Border.Background>
        </Border>
        
        <RadioButton Name="Option1RB" Content="Group by Year: get your files grouped by their creation year." HorizontalAlignment="Left" Margin="28,6,0,0" VerticalAlignment="Top" Height="20" Width="525"/>
        <RadioButton Name="Option2RB" Content="Group by Month: get your files grouped by their creation month." HorizontalAlignment="Left" Margin="28,30,0,0" VerticalAlignment="Top" Height="22" Width="525" FontFamily="Book Antiqua" FontWeight="Normal"/>
        <RadioButton Name="Option3RB" Margin="28,54,0,0" Height="32" HorizontalAlignment="Left" VerticalAlignment="Top">
            <TextBlock TextWrapping="Wrap" Width="503" Height="35"><Run Text="Group by Year and Month: get your files grouped by both year and month. Eg: "/> <Bold><Run Text="C:\Users\Admin\Documents\~_2019_~\~_June_~\YourFile.docx."/></Bold></TextBlock>
        </RadioButton>
        <RadioButton Name="Option4RB" Content="UNDO ↩ the grouping." HorizontalAlignment="Left" Margin="28,96,0,0" VerticalAlignment="Top" Height="16" Width="525"/>
        <TextBlock HorizontalAlignment="Left" Margin="28,-28,0,0" Text="1. Please choose one option:" TextWrapping="Wrap" VerticalAlignment="Top" Height="24" Width="430" AutomationProperties.IsRequiredForForm="True" FontWeight="Bold" Foreground="#FFE80A51"/>
        <TextBox Name="PathTB" HorizontalAlignment="Left" Margin="30,198,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="482" Height="24" RenderTransformOrigin="0.525,9.188">
            <TextBox.BorderBrush>
                <SolidColorBrush Color="#FF631B1B" Opacity="0.7"/>
            </TextBox.BorderBrush>
            <TextBox.Background>
                <SolidColorBrush Color="White" Opacity="0.7"/>
            </TextBox.Background>
        </TextBox>
        <Label Content="2. Path of the folder to be organized:" HorizontalAlignment="Left" Margin="31,163,0,0" VerticalAlignment="Top" FontWeight="Bold" Padding="0,0,0,0" Foreground="#FFE80A51"/>
        <Label Content="File Organizer" HorizontalAlignment="Left" Margin="7,-141,0,0" VerticalAlignment="Top" FontSize="48" Foreground="#FF150505" Padding="0,5,5,5"/>
        <Button Name="SaveBTN" Content="Save" HorizontalAlignment="Left" Margin="9,300,0,0" VerticalAlignment="Top" Height="40" Width="115" FontSize="24" Foreground="#FFFFD3D3" Cursor="Hand">
            <Button.Style>
                <Style TargetType="{x:Type Button}">
                    <Setter Property="Background" >
                        <Setter.Value>
                            <ImageBrush ImageSource="$configFilesLocationOnThisPC\fileorganizerbtn.png"></ImageBrush>
                        </Setter.Value>
                    </Setter>
                    <Setter Property="Template">
                        <Setter.Value>
                            <ControlTemplate TargetType="{x:Type Button}">
                                <Border Background="{TemplateBinding Background}">
                                    <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                                </Border>
                            </ControlTemplate>
                        </Setter.Value>
                    </Setter>
                    <Style.Triggers>
                        <Trigger Property="IsMouseOver" Value="True">
                            <Setter Property="Background" >
                                <Setter.Value>
                                    <ImageBrush ImageSource="$configFilesLocationOnThisPC\fileorganizerbtn_hover.png"></ImageBrush>
                                </Setter.Value>
                            </Setter>
                        </Trigger>
                        <Trigger Property="IsEnabled" Value="False">
                            <Setter Property="Background" >
                                <Setter.Value>
                                    <ImageBrush ImageSource="$configFilesLocationOnThisPC\fileorganizerbtn_disabled.png"></ImageBrush>
                                </Setter.Value>
                            </Setter>
                        </Trigger>
                    </Style.Triggers>
                </Style>
            </Button.Style>
        </Button>
        <Button Name="RunBTN" Content="Run" HorizontalAlignment="Left" Margin="162,300,0,0" VerticalAlignment="Top" Height="40" Width="114" Foreground="#FFFFD3D3" FontSize="24" OpacityMask="#FF631B1B" Cursor="Hand">
            <Button.Style>
                <Style TargetType="{x:Type Button}">
                    <Setter Property="Background" >
                        <Setter.Value>
                            <ImageBrush ImageSource="$configFilesLocationOnThisPC\fileorganizerbtn.png"></ImageBrush>
                        </Setter.Value>
                    </Setter>
                    <Setter Property="Template">
                        <Setter.Value>
                            <ControlTemplate TargetType="{x:Type Button}">
                                <Border Background="{TemplateBinding Background}">
                                    <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                                </Border>
                            </ControlTemplate>
                        </Setter.Value>
                    </Setter>
                    <Style.Triggers>
                        <Trigger Property="IsMouseOver" Value="True">
                            <Setter Property="Background" >
                                <Setter.Value>
                                    <ImageBrush ImageSource="$configFilesLocationOnThisPC\fileorganizerbtn_hover.png"></ImageBrush>
                                </Setter.Value>
                            </Setter>
                        </Trigger>
                        <Trigger Property="IsEnabled" Value="False">
                            <Setter Property="Background" >
                                <Setter.Value>
                                    <ImageBrush ImageSource="$configFilesLocationOnThisPC\fileorganizerbtn_disabled.png"></ImageBrush>
                                </Setter.Value>
                            </Setter>
                        </Trigger>
                    </Style.Triggers>
                </Style>
            </Button.Style>
        </Button>
       <TextBlock Name="ErrorTB" HorizontalAlignment="Left" Margin="400,304,0,0" VerticalAlignment="Bottom" Width="216" Height="89" Foreground="Red" TextWrapping="Wrap"/>
        <Image HorizontalAlignment="Left" Height="97" Margin="450,-150,0,0" VerticalAlignment="Top" Width="107" Source="$configFilesLocationOnThisPC\Logo 2.jpeg"/>
        <Button Name="browse" Content="..." HorizontalAlignment="Left" Margin="517,198,0,0" VerticalAlignment="Top" Width="25" Height="24" Background="#FFF1DFDF" BorderBrush="#FFFFFDFD" Cursor="Hand"/> 
    </Grid>
</Window>
"@

$reader = (New-Object System.Xml.XmlNodeReader $xaml)
try{$Form=[Windows.Markup.XamlReader]::Load( $reader )}
catch{Write-Host "Unable to load Windows.Markup.XamlReader"; exit}
 
<#
-> Store Form Objects In PowerShell
#>
$xaml.SelectNodes("//*[@Name]") | ForEach-Object {Set-Variable -Name ($_.Name) -Value $Form.FindName($_.Name)}

<#
-> Reading the txt files for configurations
#>

$PathTB.Text = Get-Content -Path "$configFilesLocationOnThisPC\Path.txt"
$OptionNr = Get-Content -Path "$configFilesLocationOnThisPC\Option.txt"
 
if($OptionNr -eq "1") {
    $Option1RB.IsChecked = $true
}
elseif ($OptionNr -eq "2") {
    $Option2RB.IsChecked = $true
}
elseif ($OptionNr -eq "3") {
    $Option3RB.IsChecked = $true
}
elseif ($OptionNr -eq "4") {
    $Option4RB.IsChecked = $true
}

<#
-> Adding click action to Save button and Run button
#>

function SaveConfig {
    Set-Content -Path "$configFilesLocationOnThisPC\Path.txt" -Value $PathTB.Text
    $OptionChecked =""
    if($Option1RB.IsChecked -eq $true) {
        $OptionChecked ="1"
    }
    elseif($Option2RB.IsChecked -eq $true) {
        $OptionChecked ="2"
    }
    elseif($Option3RB.IsChecked -eq $true) {
        $OptionChecked ="3"
    }
    elseif($Option4RB.IsChecked -eq $true) {
        $OptionChecked ="4"
    }
    Set-Content -Path "$configFilesLocationOnThisPC\Option.txt" -Value $OptionChecked
    $wshell = New-Object -ComObject Wscript.Shell
}

function RunOrganizeFiles {
    SaveConfig
    $a = new-object -comobject wscript.shell 
    $intAnswer = $a.popup("Successfully saved! Do you want to run the script Organize Files?", 0,"Organize Files",4) 
    If ($intAnswer -eq 6) { 
        #Invoke-Item -Path "$scriptLocationOnThisPC\Organize Files.ps1"
        Powershell.exe -executionpolicy bypass -file "$scriptLocationOnThisPC\Organize Files.ps1"
    }
}

$SaveBtn.Add_click({ 
    SaveConfig
    $wshell = new-object -comobject wscript.shell 
    $wshell.Popup("Successfully saved!",0,"Change",0x1)
})

$RunBtn.Add_click({
    RunOrganizeFiles
})
 
<#
-> Adding click action to Browse button
#> 

$browse.Add_click({
    $openFolderDialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $openFolderDialog.ShowDialog() | Out-Null
    $PathTB.Text =  $openFolderDialog.SelectedPath

})

<#
-> Load XAML elements into a hash table to be able to create the timer object
#>
$script:hash = [hashtable]::Synchronized(@{})
$hash.Window = [Windows.Markup.XamlReader]::Load((New-Object -TypeName System.Xml.XmlNodeReader -ArgumentList $xaml))
$xaml.SelectNodes("//*[@*[contains(translate(name(.),'n','N'),'Name')]]") | ForEach-Object -Process {
    $hash.$($_.Name) = $hash.Window.FindName($_.Name)
}
 
<#
-> Create a timer object to check if the buttons should be enabled
#>
$Hash.Stopwatch = New-Object System.Diagnostics.Stopwatch
$Hash.Timer = New-Object System.Windows.Forms.Timer
    $Hash.Timer.Enabled = $true
    $Hash.Timer.Interval = 55
$Hash.Stopwatch.Start()
$Hash.Timer.Add_Tick({
    $ErrorTB.Text = ""
    $NoOptionChecked = $false
    $WrongPath = $false
    $SaveBtn.IsEnabled = $true
    $RunBtn.IsEnabled = $true
    if(($Option1RB.IsChecked -eq $false) -and
    ($Option2RB.IsChecked -eq $false) -and
    ($Option3RB.IsChecked -eq $false) -and
    ($Option4RB.IsChecked -eq $false)) {
        $NoOptionChecked = $true
        $ErrorTB.Text = "No option has been chosen!"
    }
    if(($PathTB.Text).Length -eq 0) {
        $WrongPath = $true
        $ErrorTB.Text = "The path is empty!"
    }
    else {
            $path = $PathTB.Text
            if($PathTB.Text -eq 'Desktop') {
                $path = [Environment]::GetFolderPath("Desktop")
            }
            if($PathTB.Text -eq 'My Documents') {
                $path = [Environment]::GetFolderPath("MyDocuments")
            }
            if($PathTB.Text -eq 'My Pictures') {
                $path = [Environment]::GetFolderPath("MyPictures")
            }
            if($PathTB.Text -eq 'My Music') {
                $path = [Environment]::GetFolderPath("MyMusic")
            }
            if($PathTB.Text -eq 'My Videos') {
                $path = [Environment]::GetFolderPath("MyVideos")
            }
            
            $SystemDrivePath = Get-WmiObject -Class Win32_OperatingSystem -ComputerName localhost -Property SystemDrive | Select-Object -ExpandProperty SystemDrive
            if((Test-Path -Path $path) -eq $false) {
                $WrongPath = $true
                $ErrorTB.Text = "The path is invalid!"
            }
            else {
                if(($path -eq $SystemDrivePath) -or
                ((Resolve-Path -Path $path).Path -eq "$SystemDrivePath\")) {
                    $WrongPath = $true
                    $ErrorTB.Text = "You cannot input the system drive!"
                }
            }
            
    }
    if($NoOptionChecked -or $WrongPath) {
        $SaveBtn.IsEnabled = $false
        $RunBtn.IsEnabled = $false
    }
    else {
        
    }
        
})
$Hash.Timer.Start()
$Form.ShowDialog()