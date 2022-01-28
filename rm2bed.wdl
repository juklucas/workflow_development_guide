version 1.0

workflow rm2bed_workflow {

    call rm2bed 

    output {
        File rm_bed = rm2bed.rm_bed
    }
}



task rm2bed {

    input {
        String sample_name
        String output_file_tag
        File rm_out_file

        Int memSizeGB = 4
        Int diskSizeGB = 64
        String dockerImage = "juklucas/rm2bed:latest"
    }

    String output_bed_fn = "${sample_name}.${output_file_tag}_rm.bed"

    command <<<

        set -o pipefail
        set -e
        set -u
        set -o xtrace

        ## Call RM2Bed
        RM2Bed.py ~{rm_out_file}

        ## rename output
        mv *_rm.bed ~{output_bed_fn}

    >>>

    output {

        File rm_bed  = output_bed_fn
    }

    runtime {
        memory: memSizeGB + " GB"
        disks: "local-disk " + diskSizeGB + " SSD"
        docker: dockerImage
        preemptible: 1
    }
}